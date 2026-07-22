// lib/core/repositories/notification_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/must_api_service.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../models/user_model.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
    MustApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _api = apiService ?? MustApiService(DioClient.instance.dio);

  final FirebaseFirestore _firestore;
  final MustApiService _api;

  // ── Real-time stream ──────────────────────────────────────────
  Stream<List<NotificationModel>> watchNotifications() {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromFirestore).toList());
  }

  // ── Unread count ──────────────────────────────────────────────
  Stream<int> watchUnreadCount() {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ── Mark single as read ───────────────────────────────────────
  Future<Result<void>> markRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.notifications)
          .doc(notificationId)
          .update({'isRead': true});
      try {
        await _api.markNotificationRead(notificationId);
      } catch (_) {}
      return success(null);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── Mark all as read ──────────────────────────────────────────
  Future<Result<void>> markAllRead() async {
    try {
      final snap = await _firestore
          .collection(FirestoreCollections.notifications)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      try {
        await _api.markAllNotificationsRead();
      } catch (_) {}

      return success(null);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }

  // ── Send notification (admin) ─────────────────────────────────
  Future<Result<void>> sendNotification({
    required String title,
    required String titleAr,
    required String body,
    required String bodyAr,
    String? targetRole,
  }) async {
    try {
      // Save to Firestore (triggers Cloud Function → FCM)
      await _firestore
          .collection(FirestoreCollections.notifications)
          .add({
        'title': title,
        'titleAr': titleAr,
        'body': body,
        'bodyAr': bodyAr,
        'targetRole': targetRole,
        'type': 'announcement',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also call API to trigger server-side FCM batch
      try {
        await _api.sendNotification({
          'title': title,
          'title_ar': titleAr,
          'body': body,
          'body_ar': bodyAr,
          if (targetRole != null) 'target_role': targetRole,
        });
      } on DioException catch (e) {
        // API unavailable — Firestore + Cloud Function will handle delivery
        if (e.response?.statusCode == null) {
          // Offline — ignore gracefully
        } else {
          rethrow;
        }
      }

      return success(null);
    } catch (e) {
      return failure(FirestoreException(e.toString()));
    }
  }
}
