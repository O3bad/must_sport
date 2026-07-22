// lib/features/admin/bloc/admin_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/activity_repository.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/repositories/notification_repository.dart';

// ══════════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════════
sealed class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

final class AdminWatchStarted extends AdminEvent {
  const AdminWatchStarted();
}

final class AdminActivityCreateRequested extends AdminEvent {
  final Map<String, dynamic> data;
  final AppLocalizations l10n;
  const AdminActivityCreateRequested(this.data, this.l10n);
}

final class AdminActivityToggled extends AdminEvent {
  final String activityId;
  final bool newStatus;
  final AppLocalizations l10n;
  const AdminActivityToggled(this.activityId, this.newStatus, this.l10n);
  @override
  List<Object?> get props => [activityId, newStatus];
}

final class AdminUserToggled extends AdminEvent {
  final String uid;
  final bool newStatus;
  final AppLocalizations l10n;
  const AdminUserToggled(this.uid, this.newStatus, this.l10n);
  @override
  List<Object?> get props => [uid, newStatus];
}

final class AdminNotificationSent extends AdminEvent {
  final String title, titleAr, body, bodyAr;
  final String? targetRole;
  final AppLocalizations l10n;
  const AdminNotificationSent({
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    this.targetRole,
    required this.l10n,
  });
}

// Internal stream events
final class _AdminActivitiesUpdated extends AdminEvent {
  final List<ActivityModel> activities;
  const _AdminActivitiesUpdated(this.activities);
}

final class _AdminUsersUpdated extends AdminEvent {
  final List<UserModel> students;
  final List<UserModel> coaches;
  const _AdminUsersUpdated(this.students, this.coaches);
}

// ══════════════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════════════
sealed class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

final class AdminInitial extends AdminState {
  const AdminInitial();
}

final class AdminLoading extends AdminState {
  const AdminLoading();
}

final class AdminLoaded extends AdminState {
  final List<ActivityModel> activities;
  final List<UserModel> students;
  final List<UserModel> coaches;

  const AdminLoaded({
    required this.activities,
    required this.students,
    required this.coaches,
  });

  int get totalStudents => students.length;
  int get totalCoaches => coaches.length;
  int get totalActivities => activities.length;

  AdminLoaded copyWith({
    List<ActivityModel>? activities,
    List<UserModel>? students,
    List<UserModel>? coaches,
  }) =>
      AdminLoaded(
        activities: activities ?? this.activities,
        students: students ?? this.students,
        coaches: coaches ?? this.coaches,
      );

  @override
  List<Object?> get props =>
      [activities.length, students.length, coaches.length];
}

final class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

final class AdminActionInProgress extends AdminState {
  const AdminActionInProgress();
}

final class AdminError extends AdminState {
  final AppException exception;
  const AdminError(this.exception);
  String get message => exception.message;
  @override
  List<Object?> get props => [exception.code];
}

// ══════════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════════
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({
    required ActivityRepository activityRepository,
    required UserRepository userRepository,
    required NotificationRepository notificationRepository,
  })  : _activityRepo = activityRepository,
        _userRepo = userRepository,
        _notifRepo = notificationRepository,
        super(const AdminInitial()) {

    on<AdminWatchStarted>(_onWatchStarted);
    on<_AdminActivitiesUpdated>(_onActivitiesUpdated);
    on<_AdminUsersUpdated>(_onUsersUpdated);
    on<AdminActivityCreateRequested>(_onCreateActivity);
    on<AdminActivityToggled>(_onToggleActivity);
    on<AdminUserToggled>(_onToggleUser);
    on<AdminNotificationSent>(_onSendNotification);
  }

  final ActivityRepository _activityRepo;
  final UserRepository _userRepo;
  final NotificationRepository _notifRepo;

  StreamSubscription<List<ActivityModel>>? _actSub;
  StreamSubscription<List<UserModel>>? _studentSub;
  StreamSubscription<List<UserModel>>? _coachSub;

  Future<void> _onWatchStarted(
      AdminWatchStarted event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());

    await _actSub?.cancel();
    await _studentSub?.cancel();
    await _coachSub?.cancel();

    _actSub = _activityRepo.watchActivities().listen(
          (acts) => add(_AdminActivitiesUpdated(acts)));

    List<UserModel> latestStudents = [];
    List<UserModel> latestCoaches = [];

    _studentSub = _userRepo.watchUsersByRole('student').listen((s) {
      latestStudents = s;
      add(_AdminUsersUpdated(latestStudents, latestCoaches));
    });
    _coachSub = _userRepo.watchUsersByRole('coach').listen((c) {
      latestCoaches = c;
      add(_AdminUsersUpdated(latestStudents, latestCoaches));
    });
  }

  void _onActivitiesUpdated(
      _AdminActivitiesUpdated event, Emitter<AdminState> emit) {
    final current = state;
    if (current is AdminLoaded) {
      emit(current.copyWith(activities: event.activities));
    } else {
      emit(AdminLoaded(
        activities: event.activities,
        students: const [],
        coaches: const [],
      ));
    }
  }

  void _onUsersUpdated(
      _AdminUsersUpdated event, Emitter<AdminState> emit) {
    final current = state;
    if (current is AdminLoaded) {
      emit(current.copyWith(
          students: event.students, coaches: event.coaches));
    }
  }

  Future<void> _onCreateActivity(
      AdminActivityCreateRequested event, Emitter<AdminState> emit) async {
    emit(const AdminActionInProgress());
    final d = event.data;
    final result = await _activityRepo.createActivity(
      name: d['name'], nameAr: d['nameAr'], type: d['type'],
      category: d['category'], description: d['description'],
      descriptionAr: d['descriptionAr'], coachId: d['coachId'],
      coachName: d['coachName'], maxParticipants: d['maxParticipants'],
      schedule: d['schedule'], location: d['location'],
      locationAr: d['locationAr'],
    );
    result.fold(
      onSuccess: (_) => emit(AdminActionSuccess(event.l10n.activityCreated)),
      onFailure: (e) => emit(AdminError(e)),
    );
  }

  Future<void> _onToggleActivity(
      AdminActivityToggled event, Emitter<AdminState> emit) async {
    final result = await _activityRepo.toggleActivity(
        event.activityId, event.newStatus);
    result.fold(
      onSuccess: (_) =>
          emit(AdminActionSuccess(event.newStatus ? event.l10n.activated : event.l10n.deactivated)),
      onFailure: (e) => emit(AdminError(e)),
    );
  }

  Future<void> _onToggleUser(
      AdminUserToggled event, Emitter<AdminState> emit) async {
    final result =
        await _userRepo.toggleUserStatus(event.uid, event.newStatus);
    result.fold(
      onSuccess: (_) => emit(AdminActionSuccess(
          event.newStatus ? event.l10n.userActivated : event.l10n.userDeactivated)),
      onFailure: (e) => emit(AdminError(e)),
    );
  }

  Future<void> _onSendNotification(
      AdminNotificationSent event, Emitter<AdminState> emit) async {
    emit(const AdminActionInProgress());
    final result = await _notifRepo.sendNotification(
      title: event.title,
      titleAr: event.titleAr,
      body: event.body,
      bodyAr: event.bodyAr,
      targetRole: event.targetRole,
    );
    result.fold(
      onSuccess: (_) =>
          emit(AdminActionSuccess(event.l10n.notificationSent)),
      onFailure: (e) => emit(AdminError(e)),
    );
  }

  @override
  Future<void> close() {
    _actSub?.cancel();
    _studentSub?.cancel();
    _coachSub?.cancel();
    return super.close();
  }
}
