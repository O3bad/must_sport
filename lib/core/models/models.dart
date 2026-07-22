import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum EventStatus  { open, soon, full, completed }
enum BookingStatus{ confirmed, pending, cancelled, completed }
enum UserRole     { student, admin, coach }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.student => 'Student', UserRole.admin => 'Admin', UserRole.coach => 'Coach',
  };
  String get emoji => switch (this) {
    UserRole.student => '🎓', UserRole.admin => '🛡️', UserRole.coach => '🏅',
  };
  IconData get icon => switch (this) {
    UserRole.student => Icons.school_rounded,
    UserRole.admin   => Icons.admin_panel_settings_rounded,
    UserRole.coach   => Icons.sports_rounded,
  };
  bool get isAdmin => this == UserRole.admin;
  bool get isCoach => this == UserRole.coach;
}

enum SportCategory {
  football, padel, basketball, volleyball, gym, martialArts, all;
  String get displayName => switch (this) {
    SportCategory.football    => 'Football',   SportCategory.padel       => 'Padel',
    SportCategory.basketball  => 'Basketball', SportCategory.volleyball  => 'Volleyball',
    SportCategory.gym         => 'Gym',        SportCategory.martialArts => 'Martial Arts',
    SportCategory.all         => 'All',
  };
  String get emoji => switch (this) {
    SportCategory.football    => '⚽', SportCategory.padel      => '🎾',
    SportCategory.basketball  => '🏀', SportCategory.volleyball => '🏐',
    SportCategory.gym         => '🏋️', SportCategory.martialArts=> '🥋',
    SportCategory.all         => '🏅',
  };
  IconData get icon => switch (this) {
    SportCategory.football    => Icons.sports_soccer_rounded,
    SportCategory.padel       => Icons.sports_tennis_rounded,
    SportCategory.basketball  => Icons.sports_basketball_rounded,
    SportCategory.volleyball  => Icons.sports_volleyball_rounded,
    SportCategory.gym         => Icons.fitness_center_rounded,
    SportCategory.martialArts => Icons.sports_martial_arts_rounded,
    SportCategory.all         => Icons.sports_rounded,
  };
  int get activeCount => switch (this) {
    SportCategory.football => 22, SportCategory.padel => 14,
    SportCategory.basketball => 18, SportCategory.volleyball => 12,
    SportCategory.gym => 30, SportCategory.martialArts => 8,
    SportCategory.all => 0,
  };
}

class UserStats {
  final int eventsJoined, bookingsMade, wins;
  const UserStats({required this.eventsJoined, required this.bookingsMade, required this.wins});
  factory UserStats.fromJson(Map<String, dynamic> j) => UserStats(
    eventsJoined: (j['eventsJoined'] as num?)?.toInt() ?? 0,
    bookingsMade: (j['bookingsMade'] as num?)?.toInt() ?? 0,
    wins:         (j['wins']         as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'eventsJoined': eventsJoined, 'bookingsMade': bookingsMade, 'wins': wins,
  };
}

class Achievement {
  final String id, icon, label;
  final Color color;
  const Achievement({required this.id, required this.icon, required this.label, required this.color});
  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
    id: j['id'], icon: j['icon'], label: j['label'],
    color: Color(int.parse('FF${j['colorHex']}', radix: 16)),
  );
  Map<String, dynamic> toJson() => {
    'id': id, 'icon': icon, 'label': label,
    'colorHex': color.toARGB32().toRadixString(16).substring(2).toUpperCase(),
  };
}

// ─── USER MODEL — IMPROVEMENT #6: added phone and bio fields ─────────────────
class UserModel {
  final String uid;
  final UserRole role;
  final String name, studentId, email, faculty, semester;
  final String phone; // IMPROVEMENT #6
  final String bio;   // IMPROVEMENT #6
  final int points, rank;
  final double cgpa;
  final String creditHours;
  final int targetEvents;
  final UserStats stats;
  final List<Achievement> achievements;

  const UserModel({
    required this.uid, required this.role, required this.name,
    required this.studentId, required this.email, required this.faculty,
    required this.semester,
    this.phone = '',
    this.bio   = '',
    required this.points, required this.rank, required this.cgpa,
    required this.creditHours, required this.targetEvents,
    required this.stats, required this.achievements,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    uid:          (j['uid']          as String?) ?? '',
    role:         _parseRole((j['role'] as String?) ?? 'student'),
    name:         (j['name']         as String?) ?? 'Unknown',
    studentId:    (j['studentId']    as String?) ?? '',
    email:        (j['email']        as String?) ?? '',
    faculty:      (j['faculty']      as String?) ?? '',
    semester:    (j['semester']     as String?) ?? 'Spring 2026',
    phone:       (j['phone']        as String?) ?? '',
    bio:         (j['bio']          as String?) ?? '',
    points:       (j['points']       as num?)?.toInt() ?? 0,
    rank:         (j['rank']         as num?)?.toInt() ?? 0,
    cgpa:        (j['cgpa']         as num?)?.toDouble() ?? 0.0,
    creditHours: (j['creditHours']  as String?) ?? '0/140',
    targetEvents:(j['targetEvents'] as num?)?.toInt() ?? 5,
    stats: j['stats'] != null
        ? UserStats.fromJson(j['stats'] as Map<String, dynamic>)
        : const UserStats(eventsJoined: 0, bookingsMade: 0, wins: 0),
    achievements: (j['achievements'] as List<dynamic>? ?? [])
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid, 'role': role.name, 'name': name, 'studentId': studentId,
    'email': email, 'faculty': faculty, 'semester': semester,
    'phone': phone, 'bio': bio,
    'points': points, 'rank': rank, 'cgpa': cgpa,
    'creditHours': creditHours, 'targetEvents': targetEvents,
    'stats': stats.toJson(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
  };

  static UserRole _parseRole(String s) => switch (s) {
    'admin' => UserRole.admin, 'coach' => UserRole.coach, _ => UserRole.student,
  };
}

class Facility {
  final String id, name;
  final SportCategory category;
  final bool isAvailable;
  const Facility({required this.id, required this.name, required this.category, required this.isAvailable});
}

class Booking {
  final String bookingId, facilityId, facilityName, timeSlot;
  final DateTime date;
  final BookingStatus status;
  final String? studentName;
  // FIX #6: persist payment method so booking history can show it
  final String paymentMethod;
  const Booking({
    required this.bookingId, required this.facilityId, required this.facilityName,
    required this.date, required this.timeSlot, required this.status, this.studentName,
    this.paymentMethod = 'instapay',
  });
  Booking copyWith({BookingStatus? status, String? paymentMethod}) => Booking(
    bookingId: bookingId, facilityId: facilityId, facilityName: facilityName,
    date: date, timeSlot: timeSlot, status: status ?? this.status,
    studentName: studentName, paymentMethod: paymentMethod ?? this.paymentMethod,
  );
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    bookingId: j['bookingId'], facilityId: (j['facilityId'] as String?) ?? '',
    facilityName: j['facilityName'], date: DateTime.parse(j['date']),
    timeSlot: j['timeSlot'], status: _parseStatus(j['status'] as String),
    studentName: j['studentName'] as String?,
    paymentMethod: (j['paymentMethod'] as String?) ?? 'instapay',
  );
  Map<String, dynamic> toJson() => {
    'bookingId': bookingId, 'facilityId': facilityId, 'facilityName': facilityName,
    'date': date.toIso8601String(), 'timeSlot': timeSlot,
    'status': status.name, 'studentName': studentName,
    'paymentMethod': paymentMethod,
  };
  static BookingStatus _parseStatus(String s) => switch (s) {
    'confirmed' => BookingStatus.confirmed, 'cancelled' => BookingStatus.cancelled,
    'completed' => BookingStatus.completed, _ => BookingStatus.pending,
  };
}

class SportEvent {
  final String id, title, emoji, location;
  final SportCategory sportType;
  final DateTime startDate;
  final DateTime? endDate;
  int participants;
  final int maxParticipants;
  EventStatus? statusOverride;
  final EventStatus _baseStatus;

  SportEvent({
    required this.id, required this.title, required this.emoji,
    required this.sportType, required this.startDate, this.endDate,
    required this.participants, required this.maxParticipants,
    required EventStatus status, required this.location,
  }) : _baseStatus = status;

  EventStatus get status => statusOverride ?? _baseStatus;
  double get fillRatio => participants / maxParticipants;
  int    get daysLeft  => startDate.difference(DateTime.now()).inDays.clamp(0, 9999);
  int    get spotsLeft => (maxParticipants - participants).clamp(0, maxParticipants);

  String get dateRangeLabel {
    final start = _fmt(startDate);
    if (endDate == null || endDate == startDate) return start;
    return '$start – ${_fmt(endDate!)}';
  }

  static const _months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  String _fmt(DateTime d) => '${_months[d.month]} ${d.day}, ${d.year}';

  factory SportEvent.fromJson(String docId, Map<String, dynamic> j) => SportEvent(
    id: docId, title: j['title'], emoji: j['emoji'],
    sportType: SportCategory.values.byName(j['sportType'] as String),
    startDate: (j['startDate'] as Timestamp).toDate(),
    endDate: j['endDate'] != null ? (j['endDate'] as Timestamp).toDate() : null,
    participants: (j['participants'] as num).toInt(),
    maxParticipants: (j['maxParticipants'] as num).toInt(),
    status: EventStatus.values.byName(j['status'] as String),
    location: j['location'],
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'emoji': emoji, 'sportType': sportType.name,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'participants': participants, 'maxParticipants': maxParticipants,
    'status': status.name, 'location': location,
  };
}

class LeaderboardEntry {
  final int rank, points;
  final String name, faculty, initials;
  final bool isMe;
  const LeaderboardEntry({
    required this.rank, required this.name, required this.faculty,
    required this.points, required this.initials, this.isMe = false,
  });
}

class AdminStat {
  final String label, value, icon;
  final Color color;
  const AdminStat({required this.label, required this.value, required this.icon, required this.color});
}

// ─── USER MODEL COPYWITH — IMPROVEMENT #2 from original bugs: uid added ───────
extension UserModelX on UserModel {
  UserModel copyWith({
    String?   uid,
    UserRole? role,
    String?   name,
    String?   faculty,
    String?   semester,
    String?   phone,
    String?   bio,
  }) => UserModel(
    uid:          uid      ?? this.uid,
    role:         role     ?? this.role,
    name:         name     ?? this.name,
    studentId:    studentId,
    email:        email,
    faculty:      faculty  ?? this.faculty,
    semester:     semester ?? this.semester,
    phone:        phone    ?? this.phone,
    bio:          bio      ?? this.bio,
    points:       points,
    rank:         rank,
    cgpa:         cgpa,
    creditHours:  creditHours,
    targetEvents: targetEvents,
    stats:        stats,
    achievements: achievements,
  );
}
