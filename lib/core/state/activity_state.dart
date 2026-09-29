import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_models.dart';

// ─── ALL UNIVERSITY ACTIVITIES ────────────────────────────────────────────────
// (kept identical to original — full list omitted here for brevity,
//  copy kAllActivities and kFaculties from the original activity_state.dart)

const List<ActivityModel> kAllActivities = [
  ActivityModel(
      id: 'act-01',
      emoji: '⚽',
      name: 'Football',
      category: ActivityCategory.teamSports,
      slots: 22,
      description: 'Inter-faculty football league with 11v11 format.',
      schedule: 'Mon / Wed / Fri  4–7 PM',
      venue: 'Main Football Field A & B',
      coach: 'Coach Tarek Nour',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-02',
      emoji: '🎾',
      name: 'Padel Tennis',
      category: ActivityCategory.racketSports,
      slots: 14,
      description: 'Padel doubles & singles tournaments on two campus courts.',
      schedule: 'Tue / Thu  5–9 PM',
      venue: 'Padel Courts 1 & 2',
      coach: 'Coach Sara Ali',
      fee: 'Free',
      level: 'Beginner–Advanced'),
  ActivityModel(
      id: 'act-03',
      emoji: '🏀',
      name: 'Basketball',
      category: ActivityCategory.teamSports,
      slots: 18,
      description: '3v3 and 5v5 basketball competitions.',
      schedule: 'Mon / Wed  5–8 PM',
      venue: 'Gym B – Basketball Court',
      coach: 'Coach Omar Khalil',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-04',
      emoji: '🏐',
      name: 'Volleyball',
      category: ActivityCategory.teamSports,
      slots: 12,
      description: 'Mixed & gender-specific volleyball leagues.',
      schedule: 'Sun / Tue  4–7 PM',
      venue: 'Volleyball Court',
      coach: 'Coach Nour Ahmed',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-05',
      emoji: '🏋️',
      name: 'Gym & Fitness',
      category: ActivityCategory.individual,
      slots: 30,
      description: 'Fully equipped gym with personal training sessions.',
      schedule: 'Daily  7 AM – 10 PM',
      venue: 'Sports Complex – Main Gym',
      coach: 'Coach Amr Hassan',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-06',
      emoji: '🥋',
      name: 'Martial Arts',
      category: ActivityCategory.combatSports,
      slots: 8,
      description: 'Karate, Judo & Taekwondo classes for all levels.',
      schedule: 'Mon / Wed / Sat  6–8 PM',
      venue: 'Martial Arts Studio',
      coach: 'Coach Layla Ibrahim',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-07',
      emoji: '🏊',
      name: 'Swimming',
      category: ActivityCategory.aquatics,
      slots: 20,
      description: 'Competitive swimming & recreational sessions.',
      schedule: 'Daily  7–9 AM / 6–8 PM',
      venue: 'University Olympic Pool',
      coach: 'Coach Youssef Tarek',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-08',
      emoji: '🎱',
      name: 'Table Tennis',
      category: ActivityCategory.racketSports,
      slots: 16,
      description: 'Singles & doubles table tennis tournaments.',
      schedule: 'Daily  2–9 PM',
      venue: 'Recreation Hall – Tables 1–4',
      coach: 'Self-supervised',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-09',
      emoji: '🏸',
      name: 'Badminton',
      category: ActivityCategory.racketSports,
      slots: 10,
      description: 'Badminton singles and doubles for MUST students.',
      schedule: 'Sun / Tue / Thu  4–7 PM',
      venue: 'Covered Sports Hall',
      coach: 'Coach Mona Adel',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-10',
      emoji: '🤸',
      name: 'Gymnastics & Yoga',
      category: ActivityCategory.wellness,
      slots: 15,
      description:
          'Flexibility, yoga, and gymnastics for mind & body wellness.',
      schedule: 'Tue / Thu  7–8:30 AM',
      venue: 'Wellness Studio',
      coach: 'Coach Dina Mahmoud',
      fee: 'Free',
      level: 'Beginner–Intermediate'),
  ActivityModel(
      id: 'act-11',
      emoji: '🏃',
      name: 'Athletics & Running',
      category: ActivityCategory.individual,
      slots: 25,
      description: 'Track events, cross-country, and sprint training.',
      schedule: 'Mon / Wed / Fri  6–8 AM',
      venue: 'University Athletics Track',
      coach: 'Coach Ahmed Samy',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'act-12',
      emoji: '♟️',
      name: 'Chess Club',
      category: ActivityCategory.mindSports,
      slots: 20,
      description: 'University chess club with inter-faculty championships.',
      schedule: 'Sun / Wed  3–6 PM',
      venue: 'Student Union Hall B',
      coach: 'Dr. Khaled Fathi',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-01',
      emoji: '🎭',
      name: 'Acting & Theatre',
      category: ActivityCategory.performingArts,
      slots: 18,
      description: 'Explore dramatic performance and stage presence.',
      schedule: 'Mon / Wed  6–9 PM',
      venue: 'University Theatre – Black Box Studio',
      coach: 'Prof. Hana El-Sayed',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-02',
      emoji: '🎤',
      name: 'Vocal Singing',
      category: ActivityCategory.performingArts,
      slots: 20,
      description: 'Classical, contemporary, and operatic vocal training.',
      schedule: 'Tue / Thu / Sat  5–8 PM',
      venue: 'Music & Arts Centre – Vocal Studio',
      coach: 'Prof. Rania Fouad',
      fee: 'Free',
      level: 'Beginner–Advanced'),
  ActivityModel(
      id: 'art-03',
      emoji: '🎹',
      name: 'Piano & Keyboard',
      category: ActivityCategory.music,
      slots: 12,
      description: 'Individual and group piano lessons.',
      schedule: 'Daily  10 AM – 8 PM (by slot)',
      venue: 'Music & Arts Centre – Piano Room',
      coach: 'Prof. Sherif Mansour',
      fee: 'Free',
      level: 'Beginner–Advanced'),
  ActivityModel(
      id: 'art-04',
      emoji: '🎻',
      name: 'Strings Ensemble',
      category: ActivityCategory.music,
      slots: 16,
      description: 'Violin, viola, cello, and double bass training.',
      schedule: 'Mon / Wed / Fri  4–7 PM',
      venue: 'Music & Arts Centre – Ensemble Hall',
      coach: 'Prof. Dalia Mansour',
      fee: 'Free',
      level: 'Beginner–Intermediate'),
  ActivityModel(
      id: 'art-05',
      emoji: '🥁',
      name: 'Percussion & Drums',
      category: ActivityCategory.music,
      slots: 10,
      description: 'Classical percussion, drum kit, and world rhythm training.',
      schedule: 'Tue / Thu  4–7 PM',
      venue: 'Music & Arts Centre – Percussion Studio',
      coach: 'Prof. Karim Lotfy',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-06',
      emoji: '🎷',
      name: 'Wind & Brass',
      category: ActivityCategory.music,
      slots: 14,
      description: 'Flute, clarinet, saxophone, trumpet, and trombone lessons.',
      schedule: 'Sun / Tue / Thu  5–8 PM',
      venue: 'Music & Arts Centre – Wind Room',
      coach: 'Prof. Amira Saleh',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-07',
      emoji: '🎸',
      name: 'Guitar & Oud',
      category: ActivityCategory.music,
      slots: 16,
      description: 'Classical guitar, electric guitar, and Oud lessons.',
      schedule: 'Mon / Wed / Sat  3–7 PM',
      venue: 'Music & Arts Centre – String Studio',
      coach: 'Prof. Mahmoud Adel',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-08',
      emoji: '📜',
      name: 'Poetry & Spoken Word',
      category: ActivityCategory.literaryArts,
      slots: 20,
      description: 'Classical Arabic poetry and spoken word performance.',
      schedule: 'Sun / Wed  5–7 PM',
      venue: 'Humanities Building – Seminar Room 3',
      coach: 'Dr. Samira Khalil',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-09',
      emoji: '💃',
      name: 'Dance & Movement',
      category: ActivityCategory.performingArts,
      slots: 20,
      description: 'Ballet, contemporary, folkloric, and street dance.',
      schedule: 'Tue / Thu / Sat  5–8 PM',
      venue: 'Dance Studio – Arts Wing',
      coach: 'Prof. Yasmine Nour',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-10',
      emoji: '🎬',
      name: 'Opera & Musical Theatre',
      category: ActivityCategory.performingArts,
      slots: 15,
      description: 'Full opera and musical theatre production programme.',
      schedule: 'Mon / Wed / Fri  6–9 PM',
      venue: 'University Main Hall – Stage & Rehearsal',
      coach: 'Prof. Hana & Rania',
      fee: 'Free',
      level: 'Intermediate–Advanced'),
  ActivityModel(
      id: 'art-11',
      emoji: '🖼️',
      name: 'Creative Writing',
      category: ActivityCategory.literaryArts,
      slots: 18,
      description: 'Short stories, novels, screenplays, and stage scripts.',
      schedule: 'Sun / Tue  4–6 PM',
      venue: 'Humanities Building – Creative Studio',
      coach: 'Dr. Youssef Nabil',
      fee: 'Free',
      level: 'All Levels'),
  ActivityModel(
      id: 'art-12',
      emoji: '🎙️',
      name: 'Public Speaking & Debate',
      category: ActivityCategory.literaryArts,
      slots: 24,
      description: 'Oratory, rhetoric, and competitive debate.',
      schedule: 'Mon / Thu  5–7 PM',
      venue: 'Student Union Hall A',
      coach: 'Dr. Rana Ibrahim',
      fee: 'Free',
      level: 'All Levels'),
];

// The bundled activity catalog below is a development fixture, not a
// university-approved live schedule. Do not expose it to users.
const List<ActivityModel> kPublishedActivities = [];

const List<String> kFaculties = [
  'IT Faculty',
  'Engineering',
  'Medicine',
  'Pharmacy',
  'Business',
  'Law',
  'Sciences',
  'Education',
  'Architecture',
  'Nursing',
];

// ─── ACTIVITY REGISTRATION STATE — IMPROVEMENT #1 ────────────────────────────
// Registrations are now persisted to SharedPreferences so they survive restarts.
class ActivityRegistrationState extends ChangeNotifier {
  static final ActivityRegistrationState instance =
      ActivityRegistrationState._();
  ActivityRegistrationState._() {
    _ready = _load();
  }

  static const _kRegsKey = 'muster_activity_regs';
  final _uuid = const Uuid();
  final List<ActivityRegistration> _registrations = [];
  late final Future<void> _ready;

  List<ActivityRegistration> get all => List.unmodifiable(_registrations);
  List<ActivityRegistration> get pending => _registrations
      .where((r) => r.status == RegistrationStatus.pending)
      .toList();
  List<ActivityRegistration> forStudent(String email) =>
      _registrations.where((r) => r.studentEmail == email).toList();
  bool hasRegistered(String email, String activityId) => _registrations
      .any((r) => r.studentEmail == email && r.activity.id == activityId);

  // ── IMPROVEMENT #13: capacity check ──────────────────────────────────────
  /// Returns true if the activity still has slots available.
  bool hasCapacity(String activityId) {
    final activity = kPublishedActivities.where((a) => a.id == activityId);
    if (activity.isEmpty) return false;
    final approved = _registrations
        .where((r) =>
            r.activity.id == activityId &&
            r.status == RegistrationStatus.approved)
        .length;
    return approved < activity.first.slots;
  }

  void addRegistration(ActivityRegistration reg) {
    _registrations.insert(0, reg);
    _save();
    notifyListeners();
  }

  void updateStatus(String id, RegistrationStatus status) {
    final idx = _registrations.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _registrations[idx] = _registrations[idx].copyWith(status: status);
      _save();
      notifyListeners();
    }
  }

  Future<void> deleteForStudent(String email) async {
    await _ready;
    final remaining = _registrations
        .where((registration) => registration.studentEmail != email)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _kRegsKey,
      jsonEncode(remaining.map(_regToJson).toList()),
    );
    if (!saved) {
      throw StateError('Could not persist registration deletion.');
    }
    _registrations
      ..clear()
      ..addAll(remaining);
    notifyListeners();
  }

  String generateId() => _uuid.v4().substring(0, 8);

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRegsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        final loaded = list
            .map((e) => e as Map<String, dynamic>)
            .where((registration) =>
                !(registration['id'] as String).startsWith('seed-'))
            .map(_regFromJson)
            .whereType<ActivityRegistration>()
            .toList();
        _registrations.addAll(loaded);
        if (loaded.length != list.length) {
          await _save();
        }
        notifyListeners();
        return;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kRegsKey, jsonEncode(_registrations.map(_regToJson).toList()));
    } catch (_) {}
  }

  // ── JSON helpers ──────────────────────────────────────────────────────────
  Map<String, dynamic> _regToJson(ActivityRegistration r) => {
        'id': r.id,
        'studentEmail': r.studentEmail,
        'studentName': r.studentName,
        'studentId': r.studentId,
        'faculty': r.faculty,
        'phone': r.phone,
        'semester': r.semester,
        'level': r.level,
        'message': r.message,
        'activityId': r.activity.id,
        'status': r.status.name,
        'createdAt': r.createdAt.toIso8601String(),
      };

  ActivityRegistration? _regFromJson(Map<String, dynamic> j) {
    try {
      final activity = kAllActivities.firstWhere(
        (a) => a.id == j['activityId'],
      );
      final status = RegistrationStatus.values.byName(j['status'] as String);
      return ActivityRegistration(
        id: j['id'],
        studentEmail: j['studentEmail'],
        studentName: j['studentName'],
        studentId: j['studentId'],
        faculty: j['faculty'],
        phone: j['phone'],
        semester: j['semester'],
        level: j['level'],
        message: j['message'],
        activity: activity,
        status: status,
        createdAt: DateTime.parse(j['createdAt']),
      );
    } catch (_) {
      return null;
    }
  }
}
