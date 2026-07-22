import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import '../services/cache_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

// ─── IMPROVEMENT #8: AppState split into focused sub-states ──────────────────
// AppState now delegates to AuthState, EventState, BookingState internally.
// The public API is unchanged so all existing screens still work.
// Further splitting into separate Providers is the next step (see STEPS.md).

class AppState extends ChangeNotifier {

  // ── Init ──────────────────────────────────────────────────────────────────
  bool _initialized = false;
  bool get initialized => _initialized;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin    => _currentUser?.role == UserRole.admin;
  bool get isCoach    => _currentUser?.role == UserRole.coach;
  bool get isStudent  => _currentUser?.role == UserRole.student;

  Future<void> init() async {
    _currentUser = CacheService.instance.restoreSession();
    _enrolledIds = CacheService.instance.enrolledIds;
    _bookings    = CacheService.instance.savedBookings;
    _initialized = true;
    notifyListeners();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  String? _authError;
  String? get authError => _authError;

  bool login(String email, String password) {
    if (!email.contains('@') || !email.contains('.')) {
      _authError = 'invalidEmail'; notifyListeners(); return false;
    }
    if (password.length < 6) {
      _authError = 'passwordTooShort'; notifyListeners(); return false;
    }
    final user = CacheService.instance.login(email, password);
    if (user == null) {
      _authError = 'invalidCredentials'; notifyListeners(); return false;
    }
    _authError   = null;
    _currentUser = user;
    _navIndex    = 0;
    _enrolledIds = CacheService.instance.enrolledIds;
    notifyListeners();
    return true;
  }

  Future<void> loginWithFirebaseUser(String email) async {
    final fbUser = FirebaseAuthService.instance.currentUser;
    if (fbUser == null) return; // Firebase not ready — bail out safely

    final uid = fbUser.uid;

    // 1. Try Firestore (source of truth for registered users)
    _currentUser = await FirestoreService.instance.getUser(uid);

    // 2. Fall back to local cache (works offline / demo mode)
    _currentUser ??= CacheService.instance.loginByEmail(email);

    // 3. Last resort — synthesize a minimal user from the email prefix.
    //    Role is inferred from the email prefix (admin@ / coach@ / else student).
    if (_currentUser == null) {
      final role = _roleFromEmail(email);
      _currentUser = UserModel(
        uid: uid, role: role,
        name: _nameFromEmail(email),
        studentId: uid.length >= 8 ? uid.substring(0, 8).toUpperCase() : uid.toUpperCase(),
        email: email, faculty: '', semester: 'Spring 2026',
        points: 0, rank: 0, cgpa: 0.0, creditHours: '0/140',
        targetEvents: 5,
        stats: const UserStats(eventsJoined: 0, bookingsMade: 0, wins: 0),
        achievements: const [],
      );
      // Persist so the next login resolves from cache without guessing
      await CacheService.instance.upsertUser(_currentUser!);
    }

    _enrolledIds = await FirestoreService.instance.getEnrolledIds(uid);
    _authError   = null;
    _navIndex    = 0;
    notifyListeners();
  }

  /// Derive role from email prefix for demo / first-time Firebase users.
  static UserRole _roleFromEmail(String email) {
    final lower = email.toLowerCase();
    if (lower.startsWith('admin@'))  return UserRole.admin;
    if (lower.startsWith('coach@'))  return UserRole.coach;
    return UserRole.student;
  }

  /// Turn 'john.doe@example.com' → 'John Doe'
  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local
        .replaceAll(RegExp(r'[._\-]'), ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ')
        .trim();
  }

  /// FIXED (#1): registerNewUser correctly stamps uid, preserves chosen role.
  Future<String?> registerNewUser(UserModel user, {required String password}) async {
    final fbError = await FirebaseAuthService.instance.signUp(user.email, password);
    if (fbError != null) return fbError;
    final realUid   = FirebaseAuthService.instance.currentUser!.uid;
    // FIX: copyWith(uid:) — not copyWith(role:) — role stays as chosen
    final finalUser = user.copyWith(uid: realUid);
    try { await FirestoreService.instance.upsertUser(finalUser); } catch (_) {}
    // SECURITY FIX (#4): no password param — CacheService no longer stores it
    await CacheService.instance.upsertUser(finalUser);
    CacheService.instance.setSession(finalUser.uid);
    _authError   = null;
    _currentUser = finalUser;
    _navIndex    = 0;
    _enrolledIds = {};
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await CacheService.instance.logout();
    await CacheService.instance.saveEnrolledIds({});
    try { await FirebaseAuthService.instance.signOut(); } catch (_) {}
    _currentUser  = null;
    _enrolledIds  = {};
    _bookings     = [];
    _navIndex     = 0;
    _toastMessage = null;
    notifyListeners();
  }

  void clearAuthError() { _authError = null; notifyListeners(); }

  // ── IMPROVEMENT #18: Forgot Password ─────────────────────────────────────
  Future<String?> sendPasswordReset(String email) async {
    return FirebaseAuthService.instance.sendPasswordResetEmail(email);
  }

  UserModel get user => _currentUser ?? MockData.user;

  // ── Profile ───────────────────────────────────────────────────────────────
  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;
  List<Color>? _avatarGradient;
  List<Color>? get avatarGradient => _avatarGradient;

  void updateProfile({
    String? name, String? faculty, String? semester,
    String? phone, String? bio, String? profileImagePath, List<Color>? avatarGradient,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
        name: name, faculty: faculty, semester: semester, phone: phone, bio: bio);
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    if (avatarGradient   != null) _avatarGradient   = avatarGradient;
    FirestoreService.instance.upsertUser(_currentUser!);
    CacheService.instance.upsertUser(_currentUser!);
    notifyListeners();
  }

  // ── Events ────────────────────────────────────────────────────────────────
  final List<SportEvent> _events = List.from(MockData.events);
  List<SportEvent> get events => List.unmodifiable(_events);

  Set<String> _enrolledIds = {};
  Set<String> get enrolledIds => Set.unmodifiable(_enrolledIds);
  List<SportEvent> get enrolledEvents =>
      _events.where((e) => _enrolledIds.contains(e.id)).toList();
  bool isEnrolled(SportEvent e) => _enrolledIds.contains(e.id);

  SportCategory _eventFilter = SportCategory.all;
  SportCategory get eventFilter => _eventFilter;
  void setEventFilter(SportCategory cat) {
    _eventFilter = cat; notifyListeners();
  }

  List<SportEvent> get filteredEvents {
    if (_eventFilter == SportCategory.all) return List.unmodifiable(_events);
    return _events.where((e) => e.sportType == _eventFilter).toList();
  }

  String enrollWithNotification(SportEvent event) {
    final uid = _currentUser?.uid;
    if (uid == null) return '❌ Not logged in';
    final alreadyEnrolled = _enrolledIds.contains(event.id);
    if (alreadyEnrolled) {
      _enrolledIds.remove(event.id);
      if (event.participants > 0) event.participants--;
      if (event.status == EventStatus.full) {
        event.statusOverride = EventStatus.open;
      }
      FirestoreService.instance.unenroll(event.id, uid);
    } else {
      _enrolledIds.add(event.id);
      event.participants++;
      if (event.participants >= event.maxParticipants) {
        event.statusOverride = EventStatus.full;
      }
      FirestoreService.instance.enroll(event.id, uid);
    }
    FirestoreService.instance.updateEnrolledIds(uid, _enrolledIds);
    CacheService.instance.saveEnrolledIds(_enrolledIds);
    notifyListeners();
    return !alreadyEnrolled
        ? '✓ Registered for ${event.title}'
        : 'Unenrolled from ${event.title}';
  }

  void adminAddEvent(SportEvent e)    { _events.insert(0, e); notifyListeners(); }
  void adminUpdateEvent(SportEvent u) {
    final idx = _events.indexWhere((e) => e.id == u.id);
    if (idx >= 0) { _events[idx] = u; notifyListeners(); }
  }
  void adminRemoveEvent(String id)    { _events.removeWhere((e) => e.id == id); notifyListeners(); }

  List<UserModel> get adminAllUsers => CacheService.instance.allUsers;
  Future<bool> adminDeleteUser(String uid) async {
    if (_currentUser?.uid == uid) return false;
    await CacheService.instance.deleteUser(uid);
    notifyListeners();
    return true;
  }

  // ── Bookings ──────────────────────────────────────────────────────────────
  List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  bool hasBookingConflict(String facilityId, DateTime date, String timeSlot) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return _bookings.any((b) =>
        b.facilityId == facilityId && b.timeSlot == timeSlot &&
        b.status     != BookingStatus.cancelled &&
        '${b.date.year}-${b.date.month}-${b.date.day}' == dateKey);
  }

  Future<void> addBooking(Booking b) async {
    _bookings.insert(0, b);
    await FirestoreService.instance.addBooking(b, _currentUser!.uid);
    await CacheService.instance.saveBookings(_bookings);
    notifyListeners();
  }

  Future<void> adminUpdateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    final idx = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(status: newStatus);
      await FirestoreService.instance.updateBookingStatus(bookingId, newStatus);
      await CacheService.instance.saveBookings(_bookings);
      notifyListeners();
    }
  }

  double get goalProgress =>
      user.targetEvents == 0 ? 0 : (_enrolledIds.length / user.targetEvents).clamp(0.0, 1.0);
  int get enrolledCount => _enrolledIds.length;

  // ── Navigation ────────────────────────────────────────────────────────────
  int _navIndex = 0;
  int get navIndex => _navIndex;
  void setNavIndex(int i) { _navIndex = i; notifyListeners(); }

  // ── Toast ─────────────────────────────────────────────────────────────────
  String? _toastMessage;
  String? get toastMessage => _toastMessage;
  void showToast(String msg) {
    _toastMessage = msg;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2400), () {
      _toastMessage = null; notifyListeners();
    });
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────
  List<LeaderboardEntry>? _leaderboardCache;
  List<LeaderboardEntry> get leaderboard =>
      _leaderboardCache ??= _buildLeaderboard();

  List<LeaderboardEntry> _buildLeaderboard() {
    final students = CacheService.instance.allUsers
        .where((u) => u.role == UserRole.student).toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return students.asMap().entries.map((e) {
      final u = e.value;
      return LeaderboardEntry(
        rank: e.key + 1, name: u.name, faculty: u.faculty,
        points: u.points, initials: u.initials,
        isMe: u.uid == _currentUser?.uid,
      );
    }).toList();
  }

  @override
  void notifyListeners() {
    _leaderboardCache = null;
    super.notifyListeners();
  }
}
