sealed class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

// ── Network / API ────────────────────────────────────────────────
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.'])
      : super(code: 'network_error');
}

final class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out.'])
      : super(code: 'timeout');
}

final class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode})
      : super(code: 'server_error');
}

final class UnauthorisedException extends AppException {
  const UnauthorisedException(
      [super.message = 'Session expired. Please log in again.'])
      : super(code: 'unauthorised');
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.'])
      : super(code: 'not_found');
}

final class ApiParseException extends AppException {
  const ApiParseException([super.message = 'Failed to parse server response.'])
      : super(code: 'parse_error');
}

// ── Firebase / Auth ──────────────────────────────────────────────
final class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  factory AuthException.fromFirebase(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthException('No account found with this email.',
            code: 'user-not-found');
      case 'wrong-password':
        return const AuthException('Incorrect password.',
            code: 'wrong-password');
      case 'email-already-in-use':
        return const AuthException('An account already exists with this email.',
            code: 'email-already-in-use');
      case 'weak-password':
        return const AuthException('Password must be at least 6 characters.',
            code: 'weak-password');
      case 'invalid-email':
        return const AuthException('Invalid email address.',
            code: 'invalid-email');
      case 'user-disabled':
        return const AuthException('This account has been disabled.',
            code: 'user-disabled');
      case 'too-many-requests':
        return const AuthException('Too many attempts. Try again later.',
            code: 'too-many-requests');
      default:
        return AuthException('Authentication failed: $code', code: code);
    }
  }
}

final class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

// ── Business logic ───────────────────────────────────────────────
final class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation');
}

final class ActivityFullException extends AppException {
  const ActivityFullException()
      : super('This activity is full.', code: 'activity_full');
}

final class AlreadyEnrolledException extends AppException {
  const AlreadyEnrolledException()
      : super('Already enrolled in this activity.',
            code: 'already_enrolled');
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.'])
      : super(code: 'unknown');
}
