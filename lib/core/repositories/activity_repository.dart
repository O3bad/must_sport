// lib/core/repositories/activity_repository.dart
//
// Dual-source strategy:
//   • Real-time stream  → Firestore (used in BLoC StreamSubscription)
//   • One-off fetch     → REST API (used for pagination, search, stats)
//   • Writes            → BOTH (Firestore for instant UI, API for server sync)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/must_api_service.dart';
import '../api/api_models.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../models/user_model.dart';

class ActivityRepository {
  ActivityRepository({
    FirebaseFirestore? firestore,
    MustApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _api = apiService ?? MustApiService(DioClient.instance.dio);

  final FirebaseFirestore _firestore;
  final MustApiService _api;

  // ── Real-time stream (Firestore) ─────────────────────────────
  Stream<List<ActivityModel>> watchActivities({String? type}) {
    Query<Map<String, dynamic>> q = _firestore
        .collection(FirestoreCollections.activities)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);
    if (type != null) q = q.where('type', isEqualTo: type);
    return q.snapshots().map(
          (snap) => snap.docs
              .map(ActivityModel.fromFirestore)
              .toList(),
        );
  }

  Stream<List<ActivityModel>> watchEnrolledActivities(String userId) {
    return _firestore
        .collection(FirestoreCollections.activities)
        .where('enrolledStudentIds', arrayContains: userId)
        .snapshots()
        .map((s) => s.docs.map(ActivityModel.fromFirestore).toList());
  }

  Stream<List<ActivityModel>> watchCoachActivities(String coachId) {
    return _firestore
        .collection(FirestoreCollections.activities)
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((s) => s.docs.map(ActivityModel.fromFirestore).toList());
  }

  // ── Paginated fetch (API) ─────────────────────────────────────
  Future<Result<PaginatedResponse<ActivityDto>>> fetchActivities({
    String? type,
    String? search,
    int page = 1,
  }) async {
    try {
      final result = await _api.getActivities(
        type: type,
        search: search,
        page: page,
      );
      return success(result);
    } on DioException catch (e) {
      return failure(dioToAppException(e));
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Get single activity (API → fallback Firestore) ─────────────
  Future<Result<ActivityModel>> getActivity(String id) async {
    try {
      // Try API first
      final dto = await _api.getActivity(id);
      return success(_dtoToModel(dto));
    } on DioException {
      // Fallback to Firestore
      try {
        final doc = await _firestore
            .collection(FirestoreCollections.activities)
            .doc(id)
            .get();
        if (!doc.exists) return failure(const NotFoundException());
        return success(ActivityModel.fromFirestore(doc));
      } catch (e) {
        return failure(FirestoreException(e.toString()));
      }
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Enroll / Unenroll ────────────────────────────────────────
  Future<Result<void>> enroll({
    required String activityId,
    required String userId,
  }) async {
    // Validate locally first
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.activities)
          .doc(activityId)
          .get();
      if (!doc.exists) return failure(const NotFoundException());
      final act = ActivityModel.fromFirestore(doc);
      if (act.enrolledStudentIds.contains(userId)) {
        return failure(const AlreadyEnrolledException());
      }
      if (act.isFull) return failure(const ActivityFullException());
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }

    // Write to Firestore (instant UI update)
    try {
      final batch = _firestore.batch();
      final actRef = _firestore
          .collection(FirestoreCollections.activities)
          .doc(activityId);
      final userRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(userId);

      batch.update(actRef, {
        'enrolledStudentIds': FieldValue.arrayUnion([userId]),
        'currentParticipants': FieldValue.increment(1),
      });
      batch.update(userRef, {
        'enrolledActivities': FieldValue.arrayUnion([activityId]),
      });
      await batch.commit();
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }

    // Sync with API (best-effort)
    try {
      await _api.enroll(
          EnrollmentRequest(activityId: activityId, studentId: userId));
    } catch (_) {}

    return success(null);
  }

  Future<Result<void>> unenroll({
    required String activityId,
    required String userId,
  }) async {
    try {
      final batch = _firestore.batch();
      final actRef = _firestore
          .collection(FirestoreCollections.activities)
          .doc(activityId);
      final userRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(userId);

      batch.update(actRef, {
        'enrolledStudentIds': FieldValue.arrayRemove([userId]),
        'currentParticipants': FieldValue.increment(-1),
      });
      batch.update(userRef, {
        'enrolledActivities': FieldValue.arrayRemove([activityId]),
      });
      await batch.commit();
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }

    try {
      await _api.unenroll(
          EnrollmentRequest(activityId: activityId, studentId: userId));
    } catch (_) {}

    return success(null);
  }

  // ── Create activity (admin) ──────────────────────────────────
  Future<Result<ActivityModel>> createActivity({
    required String name,
    required String nameAr,
    required String type,
    required String category,
    required String description,
    required String descriptionAr,
    required String coachId,
    required String coachName,
    required int maxParticipants,
    required String schedule,
    required String location,
    required String locationAr,
  }) async {
    try {
      // Write to Firestore
      final docRef = await _firestore
          .collection(FirestoreCollections.activities)
          .add({
        'name': name, 'nameAr': nameAr, 'type': type,
        'category': category, 'description': description,
        'descriptionAr': descriptionAr, 'coachId': coachId,
        'coachName': coachName, 'maxParticipants': maxParticipants,
        'currentParticipants': 0, 'schedule': schedule,
        'location': location, 'locationAr': locationAr,
        'isActive': true, 'enrolledStudentIds': [],
        'rating': null, 'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      final model = ActivityModel.fromFirestore(doc);

      // Sync with API
      try {
        await _api.createActivity(CreateActivityRequest(
          name: name, nameAr: nameAr, type: type, category: category,
          description: description, descriptionAr: descriptionAr,
          coachId: coachId, maxParticipants: maxParticipants,
          schedule: schedule, location: location, locationAr: locationAr,
        ));
      } catch (_) {}

      return success(model);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── Toggle active status ─────────────────────────────────────
  Future<Result<void>> toggleActivity(String activityId, bool newStatus) async {
    try {
      await _firestore
          .collection(FirestoreCollections.activities)
          .doc(activityId)
          .update({'isActive': newStatus});
      try {
        await _api.toggleActivity(activityId);
      } catch (_) {}
      return success(null);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── DTO → Domain model mapper ────────────────────────────────
  ActivityModel _dtoToModel(ActivityDto dto) => ActivityModel(
        id: dto.id,
        name: dto.name,
        nameAr: dto.nameAr,
        type: dto.type,
        category: dto.category,
        description: dto.description,
        descriptionAr: dto.descriptionAr,
        coachId: dto.coachId,
        coachName: dto.coachName,
        imageUrl: dto.imageUrl,
        maxParticipants: dto.maxParticipants,
        currentParticipants: dto.currentParticipants,
        schedule: dto.schedule,
        location: dto.location,
        locationAr: dto.locationAr,
        isActive: dto.isActive,
        createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
        rating: dto.rating,
        ratingCount: dto.ratingCount,
      );
}
