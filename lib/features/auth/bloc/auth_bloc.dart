// lib/features/auth/bloc/auth_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';

// ══════════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════════
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String nameAr;
  final String role;
  final String? studentId;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.nameAr,
    required this.role,
    this.studentId,
  });
  @override
  List<Object?> get props => [email, role];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

final class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user?.uid];
}

// ══════════════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════════════
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.uid, user.role];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

final class AuthFailure extends AuthState {
  final AppException exception;
  const AuthFailure(this.exception);
  String get message => exception.message;
  @override
  List<Object?> get props => [exception.code];
}

// ══════════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════════
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _repo = authRepository,
        super(const AuthInitial()) {

    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthPasswordResetRequested>(_onPasswordReset);

    // Subscribe to Firebase auth state changes
    _authSubscription = _repo.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final AuthRepository _repo;
  late final StreamSubscription<User?> _authSubscription;

  // ── Handlers ────────────────────────────────────────────────
  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // FIX: Run auth check and splash delay truly in parallel using separate
    // futures — avoids the unsafe Future.wait List<dynamic> cast that was
    // here before (results[0] as Result<UserModel> could throw TypeError).
    final resultFuture = _repo.getCurrentUser();
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    final result = await resultFuture;
    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
      onFailure: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    // Only reload if not already showing this user
    if (state is AuthAuthenticated &&
        (state as AuthAuthenticated).user.uid == event.user!.uid) {
      return;
    }
    // FIX: Don't race against ongoing auth operations — stream events fired
    // by Firebase during sign-in / register / password-reset would overwrite
    // the loading state before the operation completes.
    if (state is AuthLoading || state is AuthPasswordResetSent) {
      return;
    }
    final result = await _repo.getCurrentUser();
    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
      onFailure: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
      onFailure: (e) => emit(AuthFailure(e)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.register(
      email: event.email,
      password: event.password,
      name: event.name,
      nameAr: event.nameAr,
      role: event.role,
      studentId: event.studentId,
    );
    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
      onFailure: (e) => emit(AuthFailure(e)),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.sendPasswordReset(event.email);
    result.fold(
      onSuccess: (_) {
        emit(const AuthPasswordResetSent());
        // FIX: Return to unauthenticated immediately so the login form
        // is re-enabled and not stuck in AuthPasswordResetSent forever.
        emit(const AuthUnauthenticated());
      },
      onFailure: (e) => emit(AuthFailure(e)),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
