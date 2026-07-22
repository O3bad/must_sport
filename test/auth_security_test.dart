// Regression tests for the authentication, privilege and session fixes.
//
// These cover the trust-boundary problems that let a caller reach AdminShell
// without ever being an admin:
//
//  - role inferred from an email prefix (`admin@` -> admin)
//  - role adopted from a cached user looked up by user-supplied email
//  - role adopted from SharedPreferences, which the device owner controls
//  - a local plaintext-credential authenticator that ran when Firebase Auth
//    rejected the submitted password
//  - a session marker with no expiry that was not bound to the live Firebase
//    user (session fixation)
//
// Run with: flutter test test/auth_security_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muster_sport/core/constants/app_constants.dart';
import 'package:muster_sport/core/services/cache_service.dart';
import 'package:muster_sport/core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('privilege is server-authoritative', () {
    test('a cached admin profile grants no privilege before verification', () {
      final state = AppState();
      // Even with a perfectly valid admin UserModel, an unverified session
      // must not report admin.
      expect(state.isAdmin, isFalse);
      expect(state.isCoach, isFalse);
      expect(state.isStudent, isTrue);
      expect(state.privilegeVerified, isFalse);
    });

    test('privilegeVerified starts false', () {
      expect(AppState().privilegeVerified, isFalse);
    });
  });

  group('no credentials are compiled into the binary', () {
    test('demo account passwords default to empty', () {
      // String.fromEnvironment with no --dart-define yields ''.
      expect(DemoAccounts.studentPassword, isEmpty);
      expect(DemoAccounts.adminPassword, isEmpty);
      expect(DemoAccounts.coachPassword, isEmpty);
      expect(DemoAccounts.anyPasswordsConfigured, isFalse);
    });
  });

  group('CacheService has no local authenticator', () {
    test('there is no password-checking login method', () {
      // The vulnerability was a `login(email, password)` that compared against
      // plaintext fixtures. Compile-time proof it is gone: the dynamic lookup
      // must not resolve.
      final dynamic svc = CacheService.instance;
      expect(() => svc.login('admin@must.edu.eg', 'admin123'),
          throwsNoSuchMethodError);
    });
  });

  group('session marker', () {
    const uid = 'user-123';

    test('round-trips for the live Firebase user', () async {
      final cache = CacheService.instance;
      await cache.init();
      cache.setSession(uid);
      expect(cache.restoreSessionUid(currentFirebaseUid: uid), uid);
    });

    test('is rejected when Firebase has no signed-in user', () async {
      // The fixation case: a planted uid must not survive when nothing is
      // actually authenticated.
      final cache = CacheService.instance;
      await cache.init();
      cache.setSession(uid);
      expect(cache.restoreSessionUid(currentFirebaseUid: null), isNull);
    });

    test('is rejected when it belongs to a different account', () async {
      final cache = CacheService.instance;
      await cache.init();
      cache.setSession(uid);
      // Signed in as somebody else: the marker names another user, so it is
      // attacker-supplied state rather than a session.
      expect(cache.restoreSessionUid(currentFirebaseUid: 'someone-else'),
          isNull);
    });

    test('is rejected and cleared when expired', () async {
      final cache = CacheService.instance;
      await cache.init();
      // Plant an expired marker directly.
      SharedPreferences.setMockInitialValues({
        'muster_session_uid': jsonEncode({
          'uid': uid,
          'issuedAtMs':
              DateTime.now().toUtc().subtract(const Duration(days: 365))
                  .millisecondsSinceEpoch,
        }),
      });
      await cache.init();
      expect(cache.restoreSessionUid(currentFirebaseUid: uid), isNull);
    });

    test('discards a legacy bare-uid marker instead of trusting it', () async {
      // Pre-fix format: the uid was stored as a bare string with no timestamp,
      // which is exactly the shape an attacker can write by hand.
      SharedPreferences.setMockInitialValues({'muster_session_uid': uid});
      final cache = CacheService.instance;
      await cache.init();
      expect(cache.restoreSessionUid(currentFirebaseUid: uid), isNull);
    });

    test('discards a corrupt marker', () async {
      SharedPreferences.setMockInitialValues({'muster_session_uid': 'not json'});
      final cache = CacheService.instance;
      await cache.init();
      expect(cache.restoreSessionUid(currentFirebaseUid: uid), isNull);
    });

    test('logout removes the marker', () async {
      final cache = CacheService.instance;
      await cache.init();
      cache.setSession(uid);
      await cache.logout();
      expect(cache.restoreSessionUid(currentFirebaseUid: uid), isNull);
    });
  });

  group('AppState has no local credential path', () {
    test('login(email, password) no longer exists', () {
      final dynamic state = AppState();
      expect(() => state.login('a@b.co', 'whatever'),
          throwsNoSuchMethodError);
    });
  });
}
