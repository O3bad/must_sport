// lib/core/api/dio_client.dart
//
// Singleton Dio instance with three interceptors:
//   1. Auth      — attaches Firebase ID token; retries once on 401
//   2. Logger    — pretty-prints requests/responses (debug only)
//   3. Error     — maps every DioException → typed AppException

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../errors/app_exception.dart';

class DioClient {
  DioClient._();
  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio dio = _createDio();

  Dio _createDio() {
    final d = Dio(
      BaseOptions(
        // Replace with your actual backend URL.
        // Use --dart-define=API_BASE_URL=https://... to inject at build time.
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.must.edu.eg/activities/v1',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout:    const Duration(seconds: 20),
        headers: {
          'Accept':        'application/json',
          'Content-Type':  'application/json',
          'X-App-Name':    'MUST-Activities',
          'X-App-Version': '1.0.0',
        },
      ),
    );

    d.interceptors.add(_AuthInterceptor());

    // Pretty logger only in debug builds
    assert(() {
      d.interceptors.add(PrettyDioLogger(
        requestHeader:  true,
        requestBody:    true,
        responseHeader: false,
        responseBody:   true,
        error:          true,
        compact:        true,
      ));
      return true;
    }());

    d.interceptors.add(_ErrorInterceptor());
    return d;
  }
}

// ── 1. Auth interceptor ───────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true); // force refresh
        final opts  = err.requestOptions
          ..headers['Authorization'] = 'Bearer $token';
        try {
          final response = await DioClient.instance.dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // Retry also failed — fall through to error mapping
        }
      }
    }
    handler.next(err);
  }
}

// ── 2. Error interceptor ──────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _map(err)));
  }

  AppException _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.badResponse:
        final status  = err.response?.statusCode ?? 0;
        final message = _extractMessage(err.response);
        // ✅ FIX: use if/else instead of switch — Dart switch patterns
        //    require language version >=3.0 with explicit enables for
        //    relational patterns on nullable int. if/else is cleaner.
        if (status == 400) return ValidationException(message);
        if (status == 401) return const UnauthorisedException();
        if (status == 403) return const UnauthorisedException('Access denied.');
        if (status == 404) return const NotFoundException();
        if (status == 422) return ValidationException(message);
        if (status == 429) {
          return const ServerException(
              'Too many requests. Please slow down.', statusCode: 429);
        }
        if (status >= 500) return ServerException(message, statusCode: status);
        return ServerException(message, statusCode: status);

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('SSL certificate error.');
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _extractMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String?
            ?? data['error']   as String?
            ?? 'Server error ${response?.statusCode ?? ''}';
      }
    } catch (_) {}
    return 'Server error ${response?.statusCode ?? ''}';
  }
}

// ── Helper: unwrap DioException → AppException ────────────────────
AppException dioToAppException(DioException e) {
  final appEx = e.error;
  if (appEx is AppException) return appEx;
  return UnknownException(e.message ?? e.toString());
}
