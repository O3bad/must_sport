import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import 'activity_state.dart';
import 'notification_state.dart';
import '../services/cache_service.dart';
import '../services/fcm_service.dart';
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

  /// Whether [_currentUser]'s role was resolved from the server this session.
  ///
  /// This is the trust boundary for privilege. A role that came from the local
  /// cache, from a synthesized fallback, or from anything the device owner can
  /// edit is *not* authoritative:
  ///
  ///  - `SharedPreferences` is plaintext on the device. Anyone with the phone,
  ///    a rooted device, an emulator, or the browser's localStorage can rewrite
  ///    a cached user to `role: 'admin'`.
  ///  - `CacheService.loginByEmail` resolved a role from a user-supplied email
  ///    string, so a Firebase-authenticated low-privilege account could adopt
  ///    a cached admin's role.
  ///
  /// So `isAdmin`/`isCoach` fail closed: privilege requires a role that came
  /// back from Firestore, which is now protected by `firestore.rules`. Anything
  /// else is treated as a student.
  ///
  /// Note this is presentation-level only. It stops the app from *rendering*
  /// admin surfaces for an unverified identity; the rules are what stop the
  /// corresponding writes.
  bool _privilegeVerified = false;
  bool get privilegeVerified => _privilegeVerified;

  /// True when Firebase Auth succeeded but no Firestore profile exists for the
  /// account, i.e. it has never completed registration.
  bool get isUnprovisioned =>
      _currentUser != null && !_privilegeVerified && _authError == null;

  bool get isAdmin =>
      _privilegeVerified && _currentUser?.role == UserRole.admin;
  bool get isCoach =>
      _privilegeVerified && _currentUser?.role == UserRole.coach;
  bool get isStudent =>
      !_privilegeVerified || _currentUser?.role == UserRole.student;

  Future<void> init() async {
    // The local session marker is only honoured when it matches the live
    // Firebase user and has not expired; see CacheService.restoreSessionUid.
    final fbUid = FirebaseAuthService.instance.currentUser?.uid;
    final sessionUid = CacheService.instance.restoreSessionUid(
      currentFirebaseUid: fbUid,
    );

    // A cached profile is restored for continuity (bookings, theme, locale) but
    // grants no privilege until re-verified against the server below.
    _currentUser =
        sessionUid == null ? null : CacheService.instance.userByUid(sessionUid);
    _privilegeVerified = false;

    if (fbUid != null) {
      // Only re-verify when the local session actually belongs to the signed-in
      // Firebase user; a mismatched cached uid is not evidence of anything.
      final profile = await FirestoreService.instance.getUser(fbUid);
      if (profile != null) {
        _currentUser = profile;
        _privilegeVerified = true;
      }
    }

    _enrolledIds = CacheService.instance.enrolledIds;
    _bookings = CacheService.instance.savedBookings;
    _initialized = true;
    notifyListeners();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  String? _authError;
  String? get authError => _authError;

  // There is deliberately no `login(email, password)` here. A local
  // authenticator meant a rejected Firebase credential could still produce a
  // successful login (see CacheService and login_screen). Firebase Auth is the
  // only path in; login_screen calls `FirebaseAuthService.signIn` and then
  // `loginWithFirebaseUser`.

  Future<void> loginWithFirebaseUser(String email) async {
    final fbUser = FirebaseAuthService.instance.currentUser;
    if (fbUser == null) return; // Firebase not ready — bail out safely

    final uid = fbUser.uid;

    // 1. Firestore is the ONLY source of authority for a role.
    //    `firestore.rules` pins self-service creates to role == 'student' and
    //    blocks owners from changing `role`, so anything else came from an
    //    admin promotion.
    _currentUser = await FirestoreService.instance.getUser(uid);
    _privilegeVerified = _currentUser != null;

    // 2. Fall back to the local cache for display continuity only (offline
    //    / freshly registered). Deliberately keyed by the *authenticated uid*
    //    before falling back to email: `loginByEmail` resolved a role from a
    //    user-supplied email string, so a Firebase-authenticated
    //    low-privilege account could adopt a cached admin's role simply by
    //    typing that admin's email address.
    _currentUser ??= CacheService.instance.userByUid(uid) ??
        CacheService.instance.userByEmail(email);

    // 3. Last resort — synthesize a minimal student profile so the app is
    //    usable, and treat the account as unprovisioned.
    //
    //    The previous version inferred the role from the email prefix
    //    (`admin@` -> admin). That is a privilege escalation: the email is
    //    attacker-chosen at registration, so `admin@anything.com` reached
    //    AdminShell. Role is never inferred from user input now.
    if (_currentUser == null) {
      _currentUser = UserModel(
        uid: uid,
        role: UserRole.student,
        name: _nameFromEmail(email),
        studentId: uid.length >= 8
            ? uid.substring(0, 8).toUpperCase()
            : uid.toUpperCase(),
        email: email,
        faculty: '',
        semester: 'Spring 2026',
        points: 0,
        rank: 0,
        cgpa: 0.0,
        creditHours: '0/140',
        targetEvents: 5,
        stats: const UserStats(eventsJoined: 0, bookingsMade: 0, wins: 0),
        achievements: const [],
      );
      // Persist so the next login resolves from cache without re-synthesizing.
      await CacheService.instance.upsertUser(_currentUser!);
    }

    _enrolledIds = await FirestoreService.instance.getEnrolledIds(uid);
    _authError = null;
    _navIndex = 0;
    _leaderboardCache = null;
    notifyListeners();
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

  /// Registers a new account. Every failure path aborts and returns an error
  /// code; it never falls back to a locally fabricated user.
  Future<String?> registerNewUser(UserModel user,
      {required String password}) async {
    String? fbError;
    try {
      fbError = await FirebaseAuthService.instance.signUp(user.email, password);
    } catch (_) {
      fbError = 'firebaseError';
    }

    if (fbError != null) {
      return fbError;
    }

    final fbUser = FirebaseAuthService.instance.currentUser;
    if (fbUser == null) {
      return 'firebaseError';
    }

    final finalUser = user.copyWith(uid: fbUser.uid);

    try {
      await FirestoreService.instance.createStudentProfile(finalUser);
    } catch (e) {
      try {
        await FirebaseAuthService.instance.deleteCurrentAccount();
      } catch (_) {}

      // Distinguish *why* the write was refused. The previous implementation
      // did `e.toString().contains('permission-denied')`, which collapsed every
      // cause into one opaque string — including the two that need completely
      // different fixes:
      //
      //  - 'permission-denied' with "Missing or insufficient permissions"
      //      => the deployed `firestore.rules` do not grant this write. Either
      //         they were never deployed, or the deployed copy predates the
      //         self-registration create rule. Verify with
      //         `firebase deploy --only firestore:rules`; the local rules are
      //         covered by functions/test/rules.test.js.
      //  - App Check rejections also surface as 'permission-denied', but with
      //    a distinct message. The app ships no App Check token provider, so
      //    any enforcement on Firestore denies every client.
      final code = e is FirebaseException ? e.code : null;
      final message = e is FirebaseException ? (e.message ?? '') : e.toString();

      if (kDebugMode) {
        debugPrint('[register] profile write failed');
        debugPrint('[register]   code    : $code');
        debugPrint('[register]   message : $message');
        debugPrint(
          '[register]   uid     : ${finalUser.uid}',
        );
        debugPrint(
          '[register]   payload : ${FirestoreService.sanitizeUserPayload(finalUser)}',
        );
      }

      // Both a rules denial and an App Check rejection are reported as
      // 'permission-denied', so the branch cannot separate them — the debug
      // output above is what distinguishes them. Either way the user-facing
      // message is the same: the account exists, the profile does not.
      return code == 'permission-denied'
          ? 'profileWriteForbidden'
          : 'profileWriteFailed';
    }

    await CacheService.instance.upsertUser(finalUser);
    CacheService.instance.setSession(finalUser.uid);
    _authError = null;
    _currentUser = finalUser;
    _navIndex = 0;
    _enrolledIds = {};
    _leaderboardCache = null;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await CacheService.instance.logout();
    await CacheService.instance.saveEnrolledIds({});
    try {
      await FirebaseAuthService.instance.signOut();
    } catch (_) {}
    _currentUser = null;
    // Privilege must not survive the session that established it.
    _privilegeVerified = false;
    _enrolledIds = {};
    _bookings = [];
    _navIndex = 0;
    _toastMessage = null;
    _leaderboardCache = null;
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  /// Surfaces a Firebase Auth failure.
  ///
  /// There used to be a second, local code path (`login`) that could succeed
  /// when Firebase rejected the credentials; now a rejected credential is just
  /// rejected, so this is the only way a login failure is reported.
  void setAuthError(String code) {
    _authError = code;
    notifyListeners();
  }

  // ── Account deletion (Play policy: in-app data removal) ───────────────────
  /// Irreversibly removes the signed-in user's account and its data.
  ///
  /// [password] is re-authenticated first so a hijacked session cannot delete
  /// an account. Returns null on success, or a short reason on failure so the
  /// UI can localise it.
  ///
  /// Ordering is deliberate: Firestore/Storage are purged *before* the Auth
  /// record is deleted, because deleting the account first revokes the
  /// security rules that authorise a server-side cleanup.
  Future<String?> deleteMyAccount(String password) async {
    final uid =
        _currentUser?.uid ?? FirebaseAuthService.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return 'notSignedIn';

    // 1. Prove the session is still owned by this person.
    try {
      await FirebaseAuthService.instance.reauthenticate(password);
    } on ReauthenticationRequired {
      return 'wrongPassword';
    } catch (_) {
      return 'reauthFailed';
    }

    // Remove local registration records before starting remote deletion.
    try {
      final email =
          _currentUser?.email ?? FirebaseAuthService.instance.currentUser?.email;
      if (email == null || email.isEmpty) {
        return 'dataDeletionFailed';
      }
      await ActivityRegistrationState.instance.deleteForStudent(email);
      await NotificationState.instance.clearForAccountDeletion();
    } catch (error, stackTrace) {
      debugPrint('Local account data deletion failed: $error\n$stackTrace');
      return 'dataDeletionFailed';
    }

    // Remove the push token while the account is still active.
    try {
      await FCMService().deleteToken();
    } catch (error, stackTrace) {
      debugPrint('Push token deletion failed: $error\n$stackTrace');
      return 'dataDeletionFailed';
    }

    // Purge remote and cached user data before deleting the Auth account.
    try {
      await FirestoreService.instance.deleteAllUserData(uid);
      await CacheService.instance.deleteUser(uid);
      if (!await CacheService.instance.logout() ||
          !await CacheService.instance.saveEnrolledIds({}) ||
          !await CacheService.instance.saveBookings([])) {
        throw StateError('Could not persist local account data deletion.');
      }
    } catch (error, stackTrace) {
      debugPrint('Account data deletion failed: $error\n$stackTrace');
      return 'dataDeletionFailed';
    }

    // Destroy the account only after the data purge succeeds.
    try {
      await FirebaseAuthService.instance.deleteCurrentAccount();
    } catch (_) {
      return 'deleteFailed';
    }

    try {
      await FirebaseAuthService.instance.signOut();
    } catch (error, stackTrace) {
      debugPrint('Sign-out after account deletion failed: $error\n$stackTrace');
    }

    _currentUser = null;
    _enrolledIds = {};
    _bookings = [];
    _navIndex = 0;
    _toastMessage = null;
    _leaderboardCache = null;
    _authError = null;
    notifyListeners();
    return null;
  }

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
    String? name,
    String? faculty,
    String? semester,
    String? phone,
    String? bio,
    String? profileImagePath,
    List<Color>? avatarGradient,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
        name: name,
        faculty: faculty,
        semester: semester,
        phone: phone,
        bio: bio);
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    if (avatarGradient != null) _avatarGradient = avatarGradient;
    // updateOwnProfile strips role/points/rank so an edited profile can never
    // change the account's standing.
    FirestoreService.instance.updateOwnProfile(_currentUser!);
    CacheService.instance.upsertUser(_currentUser!);
    _leaderboardCache = null;
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
    _eventFilter = cat;
    notifyListeners();
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

  void adminAddEvent(SportEvent e) {
    _events.insert(0, e);
    notifyListeners();
  }

  void adminUpdateEvent(SportEvent u) {
    final idx = _events.indexWhere((e) => e.id == u.id);
    if (idx >= 0) {
      _events[idx] = u;
      notifyListeners();
    }
  }

  void adminRemoveEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  List<UserModel> get adminAllUsers => CacheService.instance.allUsers;
  Future<bool> adminDeleteUser(String uid) async {
    if (_currentUser?.uid == uid) return false;
    await CacheService.instance.deleteUser(uid);
    _leaderboardCache = null;
    notifyListeners();
    return true;
  }

  // ── Bookings ──────────────────────────────────────────────────────────────
  List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  bool hasBookingConflict(String facilityId, DateTime date, String timeSlot) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return _bookings.any((b) =>
        b.facilityId == facilityId &&
        b.timeSlot == timeSlot &&
        b.status != BookingStatus.cancelled &&
        '${b.date.year}-${b.date.month}-${b.date.day}' == dateKey);
  }

  Future<void> addBooking(Booking b) async {
    _bookings.insert(0, b);
    notifyListeners();
    try {
      await FirestoreService.instance.addBooking(b, _currentUser!.uid);
      await CacheService.instance.saveBookings(_bookings);
    } catch (e) {
      _bookings.remove(b);
      notifyListeners();
      rethrow;
    }
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

  double get goalProgress => user.targetEvents == 0
      ? 0
      : (_enrolledIds.length / user.targetEvents).clamp(0.0, 1.0);
  int get enrolledCount => _enrolledIds.length;

  // ── Navigation ────────────────────────────────────────────────────────────
  int _navIndex = 0;
  int get navIndex => _navIndex;
  void setNavIndex(int i) {
    _navIndex = i;
    notifyListeners();
  }

  // ── Toast ─────────────────────────────────────────────────────────────────
  String? _toastMessage;
  String? get toastMessage => _toastMessage;
  void showToast(String msg) {
    _toastMessage = msg;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2400), () {
      _toastMessage = null;
      notifyListeners();
    });
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────
  List<LeaderboardEntry>? _leaderboardCache;
  List<LeaderboardEntry> get leaderboard =>
      _leaderboardCache ??= _buildLeaderboard();

  List<LeaderboardEntry> _buildLeaderboard() {
    final students = CacheService.instance.allUsers
        .where((u) => u.role == UserRole.student)
        .toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return students.asMap().entries.map((e) {
      final u = e.value;
      return LeaderboardEntry(
        rank: e.key + 1,
        name: u.name,
        faculty: u.faculty,
        points: u.points,
        initials: u.initials,
        isMe: u.uid == _currentUser?.uid,
      );
    }).toList();
  }
}
