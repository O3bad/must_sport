// lib/core/api/must_api_service.dart
//
// REST API client for MUST Activities backend.
// Pure Dart implementation using Dio directly — no Retrofit / build_runner needed.
// Drop-in replacement for the @RestApi annotated version.

import 'package:dio/dio.dart';
import 'api_models.dart';
import 'dio_client.dart';

class MustApiService {
  MustApiService([Dio? dio])
      : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  // ── Auth ──────────────────────────────────────────────────────

  Future<UserDto> syncUser(Map<String, dynamic> body) async {
    final r = await _dio.post<Map<String, dynamic>>('/auth/sync', data: body);
    return UserDto.fromJson(r.data!);
  }

  Future<void> updateFcmToken(Map<String, dynamic> body) async {
    await _dio.patch<void>('/auth/fcm-token', data: body);
  }

  // ── Activities ────────────────────────────────────────────────

  Future<PaginatedResponse<ActivityDto>> getActivities({
    String? type,
    String? category,
    String? search,
    int page = 1,
    int perPage = 20,
    bool activeOnly = true,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/activities',
      queryParameters: {
        if (type     != null) 'type':     type,
        if (category != null) 'category': category,
        if (search   != null) 'search':   search,
        'page':     page,
        'per_page': perPage,
        'active':   activeOnly,
      },
    );
    return PaginatedResponse.fromJson(
      r.data!, (j) => ActivityDto.fromJson(j as Map<String, dynamic>));
  }

  Future<ActivityDto> getActivity(String id) async {
    final r = await _dio.get<Map<String, dynamic>>('/activities/$id');
    return ActivityDto.fromJson(r.data!);
  }

  Future<ActivityDto> createActivity(CreateActivityRequest request) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/activities', data: request.toJson());
    return ActivityDto.fromJson(r.data!);
  }

  Future<ActivityDto> updateActivity(
      String id, Map<String, dynamic> body) async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/activities/$id', data: body);
    return ActivityDto.fromJson(r.data!);
  }

  Future<ActivityDto> toggleActivity(String id) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '/activities/$id/toggle');
    return ActivityDto.fromJson(r.data!);
  }

  Future<void> deleteActivity(String id) async {
    await _dio.delete<void>('/activities/$id');
  }

  // ── Enrollment ────────────────────────────────────────────────

  Future<void> enroll(EnrollmentRequest request) async {
    await _dio.post<void>('/enrollments', data: request.toJson());
  }

  Future<void> unenroll(EnrollmentRequest request) async {
    await _dio.delete<void>('/enrollments', data: request.toJson());
  }

  Future<List<ActivityDto>> getEnrolledActivities(String studentId) async {
    final r = await _dio.get<List<dynamic>>('/enrollments/$studentId');
    return (r.data ?? [])
        .map((j) => ActivityDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── Sessions ──────────────────────────────────────────────────

  Future<PaginatedResponse<SessionDto>> getSessions({
    String? activityId,
    String? coachId,
    int page = 1,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/sessions',
      queryParameters: {
        if (activityId != null) 'activity_id': activityId,
        if (coachId    != null) 'coach_id':    coachId,
        'page': page,
      },
    );
    return PaginatedResponse.fromJson(
      r.data!, (j) => SessionDto.fromJson(j as Map<String, dynamic>));
  }

  Future<SessionDto> createSession(Map<String, dynamic> body) async {
    final r = await _dio.post<Map<String, dynamic>>('/sessions', data: body);
    return SessionDto.fromJson(r.data!);
  }

  Future<void> markAttendance(
      String sessionId, Map<String, dynamic> body) async {
    await _dio.patch<void>('/sessions/$sessionId/attendance', data: body);
  }

  Future<SessionDto> cancelSession(String sessionId) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '/sessions/$sessionId/cancel');
    return SessionDto.fromJson(r.data!);
  }

  // ── Users ─────────────────────────────────────────────────────

  Future<PaginatedResponse<UserDto>> getUsers({
    String? role,
    String? search,
    int page = 1,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: {
        if (role   != null) 'role':   role,
        if (search != null) 'search': search,
        'page': page,
      },
    );
    return PaginatedResponse.fromJson(
      r.data!, (j) => UserDto.fromJson(j as Map<String, dynamic>));
  }

  Future<UserDto> getUser(String uid) async {
    final r = await _dio.get<Map<String, dynamic>>('/users/$uid');
    return UserDto.fromJson(r.data!);
  }

  Future<UserDto> updateUser(String uid, Map<String, dynamic> body) async {
    final r = await _dio.put<Map<String, dynamic>>('/users/$uid', data: body);
    return UserDto.fromJson(r.data!);
  }

  Future<UserDto> toggleUser(String uid) async {
    final r = await _dio.patch<Map<String, dynamic>>('/users/$uid/toggle');
    return UserDto.fromJson(r.data!);
  }

  // ── Notifications ─────────────────────────────────────────────

  Future<PaginatedResponse<NotificationDto>> getNotifications({
    int page = 1,
    bool? unreadOnly,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {
        'page': page,
        if (unreadOnly != null) 'unread': unreadOnly,
      },
    );
    return PaginatedResponse.fromJson(
      r.data!, (j) => NotificationDto.fromJson(j as Map<String, dynamic>));
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch<void>('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.patch<void>('/notifications/read-all');
  }

  Future<void> sendNotification(Map<String, dynamic> body) async {
    await _dio.post<void>('/notifications', data: body);
  }

  // ── Analytics ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final r = await _dio.get<Map<String, dynamic>>('/analytics/summary');
    return r.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getEnrollmentTrends({
    int days = 30,
  }) async {
    final r = await _dio.get<List<dynamic>>(
      '/analytics/enrollments',
      queryParameters: {'days': days},
    );
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }
}
