// lib/features/coach/bloc/coach_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/activity_repository.dart';
import '../../../core/constants/app_constants.dart';

// ══════════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════════
sealed class CoachEvent extends Equatable {
  const CoachEvent();
  @override
  List<Object?> get props => [];
}

final class CoachWatchStarted extends CoachEvent {
  final String coachId;
  const CoachWatchStarted(this.coachId);
  @override
  List<Object?> get props => [coachId];
}

final class CoachSessionCreateRequested extends CoachEvent {
  final String activityId;
  final String activityName;
  final String coachId;
  final DateTime dateTime;
  final String location;
  final int durationMinutes;
  const CoachSessionCreateRequested({
    required this.activityId,
    required this.activityName,
    required this.coachId,
    required this.dateTime,
    required this.location,
    this.durationMinutes = 90,
  });
}

final class CoachSessionCancelRequested extends CoachEvent {
  final String sessionId;
  const CoachSessionCancelRequested(this.sessionId);
}

final class _CoachActivitiesUpdated extends CoachEvent {
  final List<ActivityModel> activities;
  const _CoachActivitiesUpdated(this.activities);
}

// ══════════════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════════════
sealed class CoachState extends Equatable {
  const CoachState();
  @override
  List<Object?> get props => [];
}

final class CoachInitial extends CoachState {
  const CoachInitial();
}

final class CoachLoading extends CoachState {
  const CoachLoading();
}

final class CoachLoaded extends CoachState {
  final List<ActivityModel> activities;
  final List<SessionModel> sessions;

  const CoachLoaded({required this.activities, required this.sessions});

  int get totalStudents => activities.fold(
      0, (int sum, a) {
        return sum + a.currentParticipants;
      });

  CoachLoaded copyWith({
    List<ActivityModel>? activities,
    List<SessionModel>? sessions,
  }) =>
      CoachLoaded(
        activities: activities ?? this.activities,
        sessions: sessions ?? this.sessions,
      );

  @override
  List<Object?> get props => [activities.length, sessions.length];
}

final class CoachActionSuccess extends CoachState {
  final String message;
  const CoachActionSuccess(this.message);
}

final class CoachActionInProgress extends CoachState {
  const CoachActionInProgress();
}

final class CoachError extends CoachState {
  final AppException exception;
  const CoachError(this.exception);
  String get message => exception.message;
  @override
  List<Object?> get props => [exception.code];
}

// ══════════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════════
class CoachBloc extends Bloc<CoachEvent, CoachState> {
  CoachBloc({required ActivityRepository activityRepository})
      : _actRepo = activityRepository,
        super(const CoachInitial()) {
    on<CoachWatchStarted>(_onWatchStarted);
    on<_CoachActivitiesUpdated>(_onActivitiesUpdated);
    on<CoachSessionCreateRequested>(_onCreateSession);
    on<CoachSessionCancelRequested>(_onCancelSession);
  }

  final ActivityRepository _actRepo;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<List<ActivityModel>>? _actSub;

  Future<void> _onWatchStarted(
      CoachWatchStarted event, Emitter<CoachState> emit) async {
    emit(const CoachLoading());
    await _actSub?.cancel();
    _actSub = _actRepo.watchCoachActivities(event.coachId).listen(
          (acts) => add(_CoachActivitiesUpdated(acts)));
  }

  Future<void> _onActivitiesUpdated(
      _CoachActivitiesUpdated event, Emitter<CoachState> emit) async {
    // Also fetch sessions
    final sessionsSnap = await _firestore
        .collection(FirestoreCollections.sessions)
        .where('coachId',
            isEqualTo: event.activities.isNotEmpty
                ? event.activities.first.coachId
                : '')
        .orderBy('dateTime', descending: true)
        .limit(20)
        .get();

    final sessions =
        sessionsSnap.docs.map(SessionModel.fromFirestore).toList();

    emit(CoachLoaded(activities: event.activities, sessions: sessions));
  }

  Future<void> _onCreateSession(
      CoachSessionCreateRequested event, Emitter<CoachState> emit) async {
    emit(const CoachActionInProgress());
    try {
      await _firestore.collection(FirestoreCollections.sessions).add({
        'activityId': event.activityId,
        'activityName': event.activityName,
        'coachId': event.coachId,
        'dateTime': Timestamp.fromDate(event.dateTime),
        'durationMinutes': event.durationMinutes,
        'location': event.location,
        'notes': '',
        'attendeeIds': [],
        'isCancelled': false,
      });
      emit(const CoachActionSuccess('Session scheduled!'));
    } catch (e) {
      emit(CoachError(FirestoreException(e.toString())));
    }
  }

  Future<void> _onCancelSession(
      CoachSessionCancelRequested event, Emitter<CoachState> emit) async {
    try {
      await _firestore
          .collection(FirestoreCollections.sessions)
          .doc(event.sessionId)
          .update({'isCancelled': true});
      emit(const CoachActionSuccess('Session cancelled.'));
    } catch (e) {
      emit(CoachError(FirestoreException(e.toString())));
    }
  }

  @override
  Future<void> close() {
    _actSub?.cancel();
    return super.close();
  }
}
