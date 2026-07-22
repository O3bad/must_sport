// lib/core/repositories/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/must_api_service.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    MustApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _api = apiService ?? MustApiService(DioClient.instance.dio);

  final FirebaseFirestore _firestore;
  final MustApiService _api;

  // ── Watch a user's profile in real-time ──────────────────────
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ── Get all users (admin) ─────────────────────────────────────
  Stream<List<UserModel>> watchUsersByRole(String role) {
    return _firestore
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  // ── Fetch users via API (paginated) ──────────────────────────
  Future<Result<List<UserModel>>> fetchUsers({
    String? role,
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await _api.getUsers(
          role: role, search: search, page: page);
      final models = response.data.map((dto) => UserModel(
            uid: dto.uid,
            email: dto.email,
            name: dto.name,
            nameAr: dto.nameAr,
            role: dto.role,
            photoUrl: dto.photoUrl,
            phone: dto.phone,
            department: dto.department,
            studentId: dto.studentId,
            enrolledActivities: dto.enrolledActivities,
            isActive: dto.isActive,
            createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
          )).toList();
      return success(models);
    } on DioException catch (e) {
      return failure(dioToAppException(e));
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Update user profile ───────────────────────────────────────
  Future<Result<UserModel>> updateProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update(data);
      try {
        await _api.updateUser(uid, data);
      } catch (_) {}
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      return success(UserModel.fromFirestore(doc));
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── Toggle user active status (admin) ─────────────────────────
  Future<Result<void>> toggleUserStatus(String uid, bool isActive) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update({'isActive': isActive});
      try {
        await _api.toggleUser(uid);
      } catch (_) {}
      return success(null);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── Update FCM token ──────────────────────────────────────────
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update({'fcmToken': token});
      await _api.updateFcmToken({'uid': uid, 'token': token});
    } catch (_) {}
  }
}
