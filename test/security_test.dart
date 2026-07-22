// Regression tests for the Firestore authorization hardening.
//
// The rules themselves live in `firestore.rules` and can only be exercised
// against the Firestore emulator (needs Java, unavailable in this environment).
// What *is* testable here is the two things that silently regress in review:
//
//  1. the client-side sanitiser that strips server-owned fields, and
//  2. the presence of the load-bearing guards in `firestore.rules`.
//
// If someone re-adds Coach/Admin to the signup role list, un-strips `role` from
// the signup payload, or loosens a rule to make the app work again, one of
// these fails.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muster_sport/core/models/models.dart';
import 'package:muster_sport/core/services/firestore_service.dart';

/// A profile exactly as a malicious client would try to register it:
/// admin role, inflated points, top rank.
UserModel _hostileUser() => UserModel(
      uid: 'attacker',
      role: UserRole.admin,
      name: 'Real Name',
      studentId: '000',
      email: 's@e.edu',
      faculty: 'Engineering',
      semester: 'Spring 2026',
      phone: '555',
      points: 100000,
      rank: 1,
      cgpa: 4.0,
      creditHours: '0/140',
      targetEvents: 5,
      stats: const UserStats(eventsJoined: 0, bookingsMade: 0, wins: 0),
      achievements: [],
    );

void main() {
  group('sanitizeUserPayload', () {
    test('pins every server-owned field to a safe default', () {
      final clean = FirestoreService.sanitizeUserPayload(_hostileUser());

      // Pinned, not stripped: firestore.rules compares these against the
      // stored document, and a *missing* key is an evaluation error there
      // (not a null), which would break authorization for the account.
      expect(clean['role'], 'student');
      expect(clean['points'], 0);
      expect(clean['rank'], 0);
      expect(clean['isActive'], true);
    });

    test('never forwards a hostile role, points, rank or isActive', () {
      final clean = FirestoreService.sanitizeUserPayload(_hostileUser());

      expect(clean['role'], isNot('admin'));
      expect(clean['role'], isNot('coach'));
      expect(clean['points'], isNot(100000));
      expect(clean['rank'], isNot(1));
      expect(clean['isActive'], isTrue);
    });

    test('keeps user-controlled fields intact', () {
      final clean = FirestoreService.sanitizeUserPayload(_hostileUser());

      expect(clean['name'], 'Real Name');
      expect(clean['email'], 's@e.edu');
      expect(clean['faculty'], 'Engineering');
      expect(clean['phone'], '555');
    });

    test('does not mutate the source model\'s serialized map', () {
      final hostile = _hostileUser();
      final before = Map<String, dynamic>.of(hostile.toJson());
      FirestoreService.sanitizeUserPayload(hostile);
      expect(hostile.toJson(), equals(before));
    });

    test('a payload round-trips as a plain student', () {
      final rehydrated = UserModel.fromJson(
        FirestoreService.sanitizeUserPayload(_hostileUser()),
      );
      expect(rehydrated.role, UserRole.student);
      expect(rehydrated.points, 0);
      expect(rehydrated.rank, 0);
    });
  });

  group('firestore.rules', () {
    late String rules;
    late String firebaseJson;

    setUpAll(() {
      rules = File('firestore.rules').readAsStringSync();
      firebaseJson = File('firebase.json').readAsStringSync();
    });

    test('is wired into firebase.json', () {
      expect(firebaseJson, contains('firestore.rules'));
      expect(firebaseJson, contains('firestore.indexes.json'));
    });

    test('pins server-owned fields on create', () {
      expect(rules, contains("request.resource.data.role == 'student'"));
    });

    test('resolves privilege from the stored document, not the request', () {
      // Guards the classic bypass where a client asserts its own role.
      expect(rules, contains('storedRole(request.auth.uid)'));
      expect(rules, isNot(contains('request.resource.data.role =='
          "'admin'")));
    });

    test('prevents owner writes to server-owned fields', () {
      expect(rules, contains('serverFieldsUnchanged()'));
    });

    test('guards storedRole against a missing user document', () {
      // get() on a missing doc returns null; dereferencing .data is an
      // evaluation error that poisons every isAdmin()/isStaff() check.
      expect(rules, contains('exists(/databases/'));
    });

    test('avoids the unsupported global diff() function', () {
      // "Function not found error: Name: [diff]" in the emulator.
      // Comments are stripped first: the file deliberately documents the
      // broken approach in prose, and matching that prose would be a false
      // pass/fail.
      final code = rules
          .split('\n')
          .map((line) => line.contains('//')
              ? line.substring(0, line.indexOf('//'))
              : line)
          .join('\n');
      expect(code, isNot(contains('diff().affectedKeys()')));
    });

    test('scopes user reads to owner or admin', () {
      expect(rules, contains('allow read: if isAdmin() || isSelf(uid);'));
    });

    test('stamps booking ownership from the caller', () {
      expect(
        rules,
        contains('request.resource.data.uid == request.auth.uid'),
      );
    });

    test('reserves booking reassignment for admins', () {
      expect(
        rules,
        contains("hasOnly(['status', 'paymentMethod'])"),
      );
    });
  });
}
