// lib/core/errors/result.dart
//
// A lightweight Result monad.
// Repositories return Result<T> — BLoCs unwrap and emit states.
//
// Usage:
//   final result = await repo.getActivities();
//   result.fold(
//     onSuccess: (data) => emit(ActivitiesLoaded(data)),
//     onFailure: (e)    => emit(ActivitiesError(e)),
//   );

import 'app_exception.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get data => (this as Success<T>).value;
  AppException get error => (this as Failure<T>).exception;

  /// Map the success value to another type.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(value: final v) => Success(transform(v)),
        Failure<T>(exception: final e) => Failure(e),
      };

  /// Execute a callback and return void.
  void fold({
    required void Function(T value) onSuccess,
    required void Function(AppException error) onFailure,
  }) {
    switch (this) {
      case Success<T>(value: final v):
        onSuccess(v);
      case Failure<T>(exception: final e):
        onFailure(e);
    }
  }

  /// Async variant.
  Future<void> foldAsync({
    required Future<void> Function(T value) onSuccess,
    required Future<void> Function(AppException error) onFailure,
  }) async {
    switch (this) {
      case Success<T>(value: final v):
        await onSuccess(v);
      case Failure<T>(exception: final e):
        await onFailure(e);
    }
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

// ── Convenience constructors ─────────────────────────────────────
Result<T> success<T>(T value) => Success(value);
Result<T> failure<T>(AppException exception) => Failure(exception);

// ── Safe async wrapper ───────────────────────────────────────────
/// Wraps any async call that might throw into a Result.
Future<Result<T>> guardAsync<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } on AppException catch (e) {
    return Failure(e);
  } catch (e) {
    return Failure(UnknownException(e.toString()));
  }
}
