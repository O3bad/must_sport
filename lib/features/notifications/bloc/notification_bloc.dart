// lib/features/notifications/bloc/notification_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/notification_repository.dart';

// ══════════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════════
sealed class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

final class NotificationWatchStarted extends NotificationEvent {
  const NotificationWatchStarted();
}

final class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;
  const NotificationMarkReadRequested(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

final class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

final class _NotificationsUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;
  const _NotificationsUpdated(this.notifications);
}

final class _UnreadCountUpdated extends NotificationEvent {
  final int count;
  const _UnreadCountUpdated(this.count);
}

// ══════════════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════════════
sealed class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications.length, unreadCount];
}

final class NotificationError extends NotificationState {
  final AppException exception;
  const NotificationError(this.exception);
  String get message => exception.message;
  @override
  List<Object?> get props => [exception.code];
}

// ══════════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════════
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRepository notificationRepository})
      : _repo = notificationRepository,
        super(const NotificationInitial()) {
    on<NotificationWatchStarted>(_onWatchStarted);
    on<_NotificationsUpdated>(_onUpdated);
    on<_UnreadCountUpdated>(_onUnreadUpdated);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
  }

  final NotificationRepository _repo;
  StreamSubscription<List<NotificationModel>>? _notifSub;
  StreamSubscription<int>? _unreadSub;
  int _unreadCount = 0;

  Future<void> _onWatchStarted(
      NotificationWatchStarted event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    await _notifSub?.cancel();
    await _unreadSub?.cancel();

    _notifSub = _repo.watchNotifications().listen(
          (list) => add(_NotificationsUpdated(list)),
          onError: (e) =>
              emit(NotificationError(FirestoreException(e.toString()))),
        );
    _unreadSub = _repo.watchUnreadCount().listen(
          (count) => add(_UnreadCountUpdated(count)));
  }

  void _onUpdated(
      _NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(NotificationLoaded(
      notifications: event.notifications,
      unreadCount: _unreadCount,
    ));
  }

  void _onUnreadUpdated(
      _UnreadCountUpdated event, Emitter<NotificationState> emit) {
    _unreadCount = event.count;
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(
        notifications: current.notifications,
        unreadCount: _unreadCount,
      ));
    }
  }

  Future<void> _onMarkRead(
      NotificationMarkReadRequested event, Emitter<NotificationState> emit) async {
    await _repo.markRead(event.notificationId);
  }

  Future<void> _onMarkAllRead(
      NotificationMarkAllReadRequested event, Emitter<NotificationState> emit) async {
    await _repo.markAllRead();
  }

  @override
  Future<void> close() {
    _notifSub?.cancel();
    _unreadSub?.cancel();
    return super.close();
  }
}
