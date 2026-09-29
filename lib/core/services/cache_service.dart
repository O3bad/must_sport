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

  static const _kSession = 'muster_session_uid';
  static const _kTheme = 'muster_theme';
  static const _kLocale = 'muster_locale';
  static const _kEnrolled = 'muster_enrolled_ids';
  static const _kUsersJson = 'muster_users_json';
  static const _kBookings = 'muster_bookings';

  /// Absolute upper bound on a restored local session, regardless of activity.
  /// Firebase's own token lifetime is the real authority; this just prevents an
  /// unbounded local marker from outliving it.
  static const Duration _sessionMaxAge = Duration(days: 30);

  late SharedPreferences _prefs;
  late List<Map<String, dynamic>> _allUsers;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBundledUsers();
  }

  // Bundled demo users — used when no asset file exists (e.g. fresh clone).
  static const _kDemoUsers = [
    {
      'uid': 'demo-student-001',
      'role': 'student',
      'name': 'Mohamed Salah',
      'studentId': 'MUST-2024-0088',
      'email': 'student@must.edu.eg',
      'faculty': 'IT Faculty',
      'semester': 'Spring 2026',
      'points': 1240,
      'rank': 12,
      'cgpa': 3.43,
      'creditHours': '87/140',
      'targetEvents': 5,
      'stats': {'eventsJoined': 12, 'bookingsMade': 34, 'wins': 7},
      'achievements': [],
    },
    {
      'uid': 'demo-admin-001',
      'role': 'admin',
      'name': 'Admin User',
      'studentId': 'MUST-ADMIN-001',
      'email': 'admin@must.edu.eg',
      'faculty': 'Administration',
      'semester': 'Spring 2026',
      'points': 0,
      'rank': 0,
      'cgpa': 0.0,
      'creditHours': '0/140',
      'targetEvents': 0,
      'stats': {'eventsJoined': 0, 'bookingsMade': 0, 'wins': 0},
      'achievements': [],
    },
    {
      'uid': 'demo-coach-001',
      'role': 'coach',
      'name': 'Coach Ahmed',
      'studentId': 'MUST-COACH-001',
      'email': 'coach@must.edu.eg',
      'faculty': 'Sports Faculty',
      'semester': 'Spring 2026',
      'points': 0,
      'rank': 0,
      'cgpa': 0.0,
      'creditHours': '0/140',
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
    final saved =
        await _prefs.setString(_kUsersJson, jsonEncode({'users': sanitised}));
    if (!saved) {
      throw StateError('Could not persist cached user data.');
    }
  }

  // ── AUTH ─────────────────────────────────────────────────────────────────
  // NOTE: this class authenticates nothing.
  //
  // There used to be a `login(email, password)` here that compared a submitted
  // password against plaintext `password` fields in `_kDemoUsers` and returned
  // a UserModel — including `demo-admin-001`, whose role is admin. Two problems:
  //   1. the credentials were compiled into the release binary, so anyone who
  //      unzipped the APK could log in as the admin demo account, and
  //   2. login_screen called it whenever Firebase Auth rejected the submitted
  //      credentials, making "wrong password" a path to a successful login.
  //
  // The passwords have been removed from source and the local authenticator
  // deleted. Firebase Auth is the only authentication authority. The demo
  // accounts still exist as *profiles* (so the UI has something to show) but
  // they carry no credential and no privilege until Firebase says so.

  /// Looks up a cached profile by uid. Read-only: it never writes a session
  /// marker, because a lookup is not an authentication event.
  ///
  /// Used for display continuity only — privilege is decided by
  /// `AppState.privilegeVerified`.
  UserModel? userByUid(String uid) {
    final match =
        _allUsers.firstWhere((u) => u['uid'] == uid, orElse: () => {});
    return match.isEmpty ? null : UserModel.fromJson(match);
  }

  UserModel? userByEmail(String email) {
    final match = _allUsers.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    return match.isEmpty ? null : UserModel.fromJson(match);
  }

  /// Restores the cached session marker.
  ///
  /// Returns `null` unless the stored session is well-formed, unexpired, and
  /// actually belongs to the currently signed-in Firebase user. Returns the uid
  /// rather than a UserModel on purpose: the *role* that comes with it is
  /// device-local data and is never treated as authoritative
  /// (see AppState.privilegeVerified).
  ///
  /// Why this is stricter than before: the marker used to be a bare uid string
  /// written by `setSession` with no timestamp and no check against the live
  /// Firebase session. Any process with access to SharedPreferences (or the
  /// browser's localStorage on web) could plant a uid — including one belonging
  /// to a different account than the one that is actually authenticated — and
  /// the app would adopt it on next launch. That is a session-fixation shape:
  /// an attacker-supplied identifier surviving re-authentication.
  String? restoreSessionUid({required String? currentFirebaseUid}) {
    final raw = _prefs.getString(_kSession);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final uid = decoded['uid'] as String?;
      final issuedAt =
          DateTime.fromMillisecondsSinceEpoch(decoded['issuedAtMs'] as int)
              .toUtc();
      if (uid == null || uid.isEmpty) return null;

      // Absolute ceiling, so a long-lived device cannot hold a session forever.
      if (DateTime.now().toUtc().difference(issuedAt) > _sessionMaxAge) {
        _prefs.remove(_kSession);
        return null;
      }

      // A session marker for anyone other than the live Firebase user is
      // attacker-plantable state, not a session.
      if (currentFirebaseUid == null || currentFirebaseUid != uid) {
        _prefs.remove(_kSession);
        return null;
      }
      return uid;
    } catch (_) {
      // Pre-JSON (bare uid) or corrupt: discard rather than trust.
      _prefs.remove(_kSession);
      return null;
    }
  }

  /// Rotates the session marker. Called on every successful authentication and
  /// on privilege changes, so a pre-existing marker is never reused.
  void setSession(String uid) => _prefs.setString(
        _kSession,
        jsonEncode({
          'uid': uid,
          'issuedAtMs': DateTime.now().toUtc().millisecondsSinceEpoch,
        }),
      );

  Future<bool> logout() => _prefs.remove(_kSession);

  // ── THEME / LOCALE ───────────────────────────────────────────────────────
  String get savedTheme => _prefs.getString(_kTheme) ?? 'dark';
  Future<void> saveTheme(String mode) => _prefs.setString(_kTheme, mode);
  String get savedLocale => _prefs.getString(_kLocale) ?? 'en';
  Future<void> saveLocale(String code) => _prefs.setString(_kLocale, code);

  // ── ENROLLED IDS ─────────────────────────────────────────────────────────
  Set<String> get enrolledIds =>
      (_prefs.getStringList(_kEnrolled) ?? []).toSet();
  Future<bool> saveEnrolledIds(Set<String> ids) =>
      _prefs.setStringList(_kEnrolled, ids.toList());

  // ── BOOKINGS ─────────────────────────────────────────────────────────────
  List<Booking> get savedBookings {
    final raw = _prefs.getString(_kBookings);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveBookings(List<Booking> bookings) => _prefs.setString(
      _kBookings, jsonEncode(bookings.map((b) => b.toJson()).toList()));

  // ── USER LIST ────────────────────────────────────────────────────────────
  List<UserModel> get allUsers =>
      _allUsers.map((j) => UserModel.fromJson(j)).toList();

  /// Upsert user profile — NO password parameter (Firebase owns auth).
  Future<void> upsertUser(UserModel user) async {
    final idx = _allUsers.indexWhere((u) => u['uid'] == user.uid);
    final json = user.toJson();
    if (idx >= 0) {
      _allUsers[idx] = json;
    } else {
      _allUsers.add(json);
    }
    await _persistUsers();
  }

  Future<void> deleteUser(String uid) async {
    _allUsers.removeWhere((u) => u['uid'] == uid);
    await _persistUsers();
  }
}
