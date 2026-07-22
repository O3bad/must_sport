import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// CacheService — local persistence layer.
///
/// SECURITY FIX (#4): Passwords are NO LONGER stored in the local cache.
/// Firebase handles all authentication. The local cache only stores the
/// user profile needed to restore the UI session.
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const _kSession   = 'muster_session_uid';
  static const _kTheme     = 'muster_theme';
  static const _kLocale    = 'muster_locale';
  static const _kEnrolled  = 'muster_enrolled_ids';
  static const _kUsersJson = 'muster_users_json';
  static const _kBookings  = 'muster_bookings';

  late SharedPreferences _prefs;
  late List<Map<String, dynamic>> _allUsers;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBundledUsers();
  }

  // Bundled demo users — used when no asset file exists (e.g. fresh clone).
  static const _kDemoUsers = [
    {
      'uid': 'demo-student-001', 'role': 'student',
      'name': 'Mohamed Salah', 'studentId': 'MUST-2024-0088',
      'email': 'student@must.edu.eg', 'password': 'student123',
      'faculty': 'IT Faculty', 'semester': 'Spring 2026',
      'points': 1240, 'rank': 12, 'cgpa': 3.43, 'creditHours': '87/140',
      'targetEvents': 5,
      'stats': {'eventsJoined': 12, 'bookingsMade': 34, 'wins': 7},
      'achievements': [],
    },
    {
      'uid': 'demo-admin-001', 'role': 'admin',
      'name': 'Admin User', 'studentId': 'MUST-ADMIN-001',
      'email': 'admin@must.edu.eg', 'password': 'admin123',
      'faculty': 'Administration', 'semester': 'Spring 2026',
      'points': 0, 'rank': 0, 'cgpa': 0.0, 'creditHours': '0/140',
      'targetEvents': 0,
      'stats': {'eventsJoined': 0, 'bookingsMade': 0, 'wins': 0},
      'achievements': [],
    },
    {
      'uid': 'demo-coach-001', 'role': 'coach',
      'name': 'Coach Ahmed', 'studentId': 'MUST-COACH-001',
      'email': 'coach@must.edu.eg', 'password': 'coach123',
      'faculty': 'Sports Faculty', 'semester': 'Spring 2026',
      'points': 0, 'rank': 0, 'cgpa': 0.0, 'creditHours': '0/140',
      'targetEvents': 0,
      'stats': {'eventsJoined': 0, 'bookingsMade': 0, 'wins': 0},
      'achievements': [],
    },
  ];

  Future<void> _loadBundledUsers() async {
    // 1. Prefer previously-persisted user list (includes registered users)
    final stored = _prefs.getString(_kUsersJson);
    if (stored != null) {
      try {
        final decoded = jsonDecode(stored) as Map<String, dynamic>;
        _allUsers = List<Map<String, dynamic>>.from(decoded['users'] as List);
        return;
      } catch (_) {
        // Corrupted cache — fall through and rebuild
        await _prefs.remove(_kUsersJson);
      }
    }

    // 2. Try to load from the bundled asset file
    try {
      final raw = await rootBundle.loadString('assets/users_cache.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _allUsers = List<Map<String, dynamic>>.from(decoded['users'] as List);
      await _persistUsers();
      return;
    } catch (_) {
      // Asset missing (common in fresh checkouts) — seed from inline defaults
    }

    // 3. Use hardcoded demo users so the app is always usable offline
    _allUsers = _kDemoUsers.map((u) => Map<String, dynamic>.from(u)).toList();
    await _persistUsers();
  }

  Future<void> _persistUsers() async {
    // SECURITY FIX: strip any legacy 'password' field before writing to disk
    final sanitised = _allUsers.map((u) {
      final copy = Map<String, dynamic>.from(u);
      copy.remove('password');
      return copy;
    }).toList();
    await _prefs.setString(_kUsersJson, jsonEncode({'users': sanitised}));
  }

  // ── AUTH ─────────────────────────────────────────────────────────────────
  // login() is kept ONLY for the offline/demo fallback.
  // Passwords are checked transiently against bundled demo data — never stored.
  UserModel? login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    // Demo credentials must keep working even after cached users are
    // sanitised (password field removed).
    final isValidDemoCred = _kDemoUsers.any(
      (u) =>
          (u['email'] as String).toLowerCase() == normalizedEmail &&
          (u['password'] as String) == normalizedPassword,
    );
    if (!isValidDemoCred) return null;

    // Prefer the latest profile from cache (it may include user edits).
    final cached = _allUsers.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
      orElse: () => {},
    );
    final source = cached.isNotEmpty
        ? cached
        : _kDemoUsers.firstWhere(
            (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
          );

    final user = UserModel.fromJson(source);
    _prefs.setString(_kSession, user.uid);
    return user;
  }

  UserModel? loginByEmail(String email) {
    final match = _allUsers.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    if (match.isEmpty) return null;
    final user = UserModel.fromJson(match);
    _prefs.setString(_kSession, user.uid);
    return user;
  }

  UserModel? restoreSession() {
    final uid = _prefs.getString(_kSession);
    if (uid == null) return null;
    final match = _allUsers.firstWhere(
        (u) => u['uid'] == uid, orElse: () => {});
    if (match.isEmpty) return null;
    return UserModel.fromJson(match);
  }

  void setSession(String uid) => _prefs.setString(_kSession, uid);
  Future<void> logout() async => _prefs.remove(_kSession);

  // ── THEME / LOCALE ───────────────────────────────────────────────────────
  String get savedTheme  => _prefs.getString(_kTheme)  ?? 'dark';
  Future<void> saveTheme(String mode) => _prefs.setString(_kTheme, mode);
  String get savedLocale => _prefs.getString(_kLocale) ?? 'en';
  Future<void> saveLocale(String code) => _prefs.setString(_kLocale, code);

  // ── ENROLLED IDS ─────────────────────────────────────────────────────────
  Set<String> get enrolledIds =>
      (_prefs.getStringList(_kEnrolled) ?? []).toSet();
  Future<void> saveEnrolledIds(Set<String> ids) =>
      _prefs.setStringList(_kEnrolled, ids.toList());

  // ── BOOKINGS ─────────────────────────────────────────────────────────────
  List<Booking> get savedBookings {
    final raw = _prefs.getString(_kBookings);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) { return []; }
  }

  Future<void> saveBookings(List<Booking> bookings) =>
      _prefs.setString(_kBookings,
          jsonEncode(bookings.map((b) => b.toJson()).toList()));

  // ── USER LIST ────────────────────────────────────────────────────────────
  List<UserModel> get allUsers =>
      _allUsers.map((j) => UserModel.fromJson(j)).toList();

  /// Upsert user profile — NO password parameter (Firebase owns auth).
  Future<void> upsertUser(UserModel user) async {
    final idx = _allUsers.indexWhere((u) => u['uid'] == user.uid);
    final json = user.toJson();
    if (idx >= 0) { _allUsers[idx] = json; } else { _allUsers.add(json); }
    await _persistUsers();
  }

  Future<void> deleteUser(String uid) async {
    _allUsers.removeWhere((u) => u['uid'] == uid);
    await _persistUsers();
  }
}
