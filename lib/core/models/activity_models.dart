import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

// ─── ACTIVITY CATEGORY ────────────────────────────────────────────────────────
enum ActivityCategory {
  teamSports,
  racketSports,
  individual,
  combatSports,
  aquatics,
  wellness,
  mindSports,
  // ── Performing Arts (new) ──────────────────────────────────────
  performingArts,
  music,
  literaryArts;

  String displayName(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (this) {
      ActivityCategory.teamSports    => l.catTeamSports,
      ActivityCategory.racketSports  => l.catRacketSports,
      ActivityCategory.individual    => l.catIndividual,
      ActivityCategory.combatSports  => l.catCombatSports,
      ActivityCategory.aquatics      => l.catAquatics,
      ActivityCategory.wellness      => l.catWellness,
      ActivityCategory.mindSports    => l.catMindSports,
      ActivityCategory.performingArts=> l.catPerformingArts,
      ActivityCategory.music         => l.catMusic,
      ActivityCategory.literaryArts  => l.catLiteraryArts,
    };
  }

  String get emoji => switch (this) {
    ActivityCategory.teamSports    => '⚽',
    ActivityCategory.racketSports  => '🎾',
    ActivityCategory.individual    => '🏃',
    ActivityCategory.combatSports  => '🥋',
    ActivityCategory.aquatics      => '🏊',
    ActivityCategory.wellness      => '🧘',
    ActivityCategory.mindSports    => '♟️',
    ActivityCategory.performingArts=> '🎭',
    ActivityCategory.music         => '🎵',
    ActivityCategory.literaryArts  => '📜',
  };

  IconData get icon => switch (this) {
    ActivityCategory.teamSports    => Icons.groups_rounded,
    ActivityCategory.racketSports  => Icons.sports_tennis_rounded,
    ActivityCategory.individual    => Icons.directions_run_rounded,
    ActivityCategory.combatSports  => Icons.sports_martial_arts_rounded,
    ActivityCategory.aquatics      => Icons.pool_rounded,
    ActivityCategory.wellness      => Icons.self_improvement_rounded,
    ActivityCategory.mindSports    => Icons.psychology_rounded,
    ActivityCategory.performingArts=> Icons.theater_comedy_rounded,
    ActivityCategory.music         => Icons.music_note_rounded,
    ActivityCategory.literaryArts  => Icons.menu_book_rounded,
  };

  /// Whether this is a performing/cultural arts category
  bool get isArts => this == ActivityCategory.performingArts ||
      this == ActivityCategory.music ||
      this == ActivityCategory.literaryArts;
}

// ─── ACTIVITY MODEL ───────────────────────────────────────────────────────────
class ActivityModel {
  final String           id;
  final String           emoji;
  final String           name;
  final ActivityCategory category;
  final int              slots;
  final String           description;
  final String           schedule;
  final String           venue;
  final String           coach;
  final String           fee;
  final String           level;

  const ActivityModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.slots,
    required this.description,
    required this.schedule,
    required this.venue,
    required this.coach,
    required this.fee,
    required this.level,
  });
}

// ─── REGISTRATION STATUS ──────────────────────────────────────────────────────
enum RegistrationStatus { pending, approved, rejected }

extension RegistrationStatusX on RegistrationStatus {
  String get label => switch (this) {
    RegistrationStatus.pending  => 'Pending',
    RegistrationStatus.approved => 'Approved',
    RegistrationStatus.rejected => 'Rejected',
  };
  String get emoji => switch (this) {
    RegistrationStatus.pending  => '⏳',
    RegistrationStatus.approved => '✅',
    RegistrationStatus.rejected => '❌',
  };
  IconData get icon => switch (this) {
    RegistrationStatus.pending  => Icons.hourglass_empty_rounded,
    RegistrationStatus.approved => Icons.check_circle_rounded,
    RegistrationStatus.rejected => Icons.cancel_rounded,
  };
  Color get color => switch (this) {
    RegistrationStatus.pending  => const Color(0xFFFFB547),
    RegistrationStatus.approved => const Color(0xFFA8FF3E),
    RegistrationStatus.rejected => const Color(0xFFFF4757),
  };
}

// ─── ACTIVITY REGISTRATION ────────────────────────────────────────────────────
class ActivityRegistration {
  final String             id;
  final String             studentEmail;
  final String             studentName;
  final String             studentId;
  final String             faculty;
  final String             phone;
  final String             semester;
  final String             level;
  final String             message;
  final ActivityModel      activity;
  RegistrationStatus       status;
  final DateTime           createdAt;

  ActivityRegistration({
    required this.id,
    required this.studentEmail,
    required this.studentName,
    required this.studentId,
    required this.faculty,
    required this.phone,
    required this.semester,
    required this.level,
    required this.message,
    required this.activity,
    this.status = RegistrationStatus.pending,
    required this.createdAt,
  });

  ActivityRegistration copyWith({RegistrationStatus? status}) =>
      ActivityRegistration(
        id:           id,
        studentEmail: studentEmail,
        studentName:  studentName,
        studentId:    studentId,
        faculty:      faculty,
        phone:        phone,
        semester:     semester,
        level:        level,
        message:      message,
        activity:     activity,
        status:       status ?? this.status,
        createdAt:    createdAt,
      );

  String get dateLabel {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[createdAt.month]} ${createdAt.day}, ${createdAt.year}';
  }
}
