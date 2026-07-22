// lib/core/di/service_locator.dart
//
// Lightweight manual DI container.
// All repositories and service singletons are registered here.

import '../api/dio_client.dart';
import '../api/must_api_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/activity_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/notification_repository.dart';
import '../services/photo_upload_service.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  // ── Lazy singletons ──────────────────────────────────────────
  late final MustApiService apiService = MustApiService(DioClient.instance.dio);

  late final AuthRepository authRepository = AuthRepository(
    apiService: apiService,
  );

  late final ActivityRepository activityRepository = ActivityRepository(
    apiService: apiService,
  );

  late final UserRepository userRepository = UserRepository(
    apiService: apiService,
  );

  late final NotificationRepository notificationRepository =
      NotificationRepository(
    apiService: apiService,
  );

  // Photo upload — uses Firebase Storage
  late final PhotoUploadService photoUploadService = PhotoUploadService();
}

// Convenience alias
ServiceLocator get sl => ServiceLocator.instance;
