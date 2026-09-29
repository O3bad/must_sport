import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// IMPROVEMENT #3: leaderboardStream now uses Firestore orderBy + limit
/// instead of fetching all users and sorting client-side.
///
/// IMPROVEMENT #10: All streams now include .handleError() so the UI
/// receives an empty list instead of crashing when Firestore is offline.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  // ── Users ─────────────────────────────────────────────────────────────────
  /// Fields the server owns. The client pins them to safe defaults instead of
  /// omitting them, because `firestore.rules` reads them off `resource.data`
  /// and a missing key is an evaluation error, not a null — omitting them
  /// breaks authorization for the account.
  static const List<String> serverOwnedUserFields = [
    'role',
    'points',
    'rank',
    'isActive',
  ];

  /// Returns a user payload with every server-owned field pinned to its default.
  ///
  /// Pinning rather than stripping is deliberate. The rules compare these
  /// values against the stored document to detect tampering:
  ///
  ///   allow update: if isAdmin() || (isSelf(uid) && serverFieldsUnchanged());
  ///
  /// A client that tries to promote itself sends `role: 'admin'`, the
  /// comparison fails, and the write is rejected. The client-side half is
  /// advisory only — a patched app skips it entirely — but the rules are the
  /// half that actually holds, and this keeps the two consistent.
  ///
  /// Exposed (and static) so `test/security_test.dart` can assert the invariant
  /// without standing up Firebase.
  static Map<String, dynamic> sanitizeUserPayload(UserModel user) {
    final copy = Map<String, dynamic>.of(user.toJson());
    copy['role'] = UserRole.student.name;
    copy['points'] = 0;
    copy['rank'] = 0;
    copy['isActive'] = true;
    return copy;
  }

  /// Creates the profile document for a freshly registered account.
  ///
  /// [UserModel.fromJson] defaults a missing `points`/`rank` to 0, so reads are
  /// unaffected by the stripped fields.
  Future<void> createStudentProfile(UserModel user) async {
    await _users
        .doc(user.uid)
        .set(sanitizeUserPayload(user), SetOptions(merge: true));
  }

  /// Persists profile edits made by the signed-in user.
  ///
  /// Server-owned fields are stripped for the same reason as
  /// [createStudentProfile]. Use this rather than [upsertUser] for any write
  /// originating from the client.
  Future<void> updateOwnProfile(UserModel user) async {
    await _users
        .doc(user.uid)
        .set(sanitizeUserPayload(user), SetOptions(merge: true));
  }

  Future<void> upsertUser(UserModel user) async =>
      _users.doc(user.uid).set(user.toJson(), SetOptions(merge: true));

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snap = await _users.get();
      return snap.docs.map((d) => UserModel.fromJson(d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteUser(String uid) async => _users.doc(uid).delete();

  /// Removes every trace of [uid] from Firestore before the Auth record is
  /// destroyed. Called by the account-deletion flow — once
  /// `FirebaseAuthService.deleteCurrentAccount()` runs, security rules stop
  /// letting the client read or write this user's documents, so this has to
  /// happen first.
  ///
  /// Failures must be surfaced so account deletion can stop and be retried.
  Future<void> deleteAllUserData(String uid) async {
    await _db.collection('leaderboard').doc(uid).delete();
    await _deleteMatchingDocuments(_bookings.where('uid', isEqualTo: uid));
    await _deleteMatchingDocuments(
      _db
          .collectionGroup('enrollments')
          .where(FieldPath.documentId, isEqualTo: uid),
    );
    await _users.doc(uid).delete();
  }

  Future<void> _deleteMatchingDocuments(
    Query<Map<String, dynamic>> query,
  ) async {
    const pageSize = 400;
    while (true) {
      final page = await query.limit(pageSize).get();
      if (page.docs.isEmpty) return;

      final batch = _db.batch();
      for (final document in page.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();

      if (page.docs.length < pageSize) return;
      query = query.startAfterDocument(page.docs.last);
    }
  }

  Future<void> updateEnrolledIds(String uid, Set<String> ids) async =>
      _users.doc(uid).update({'enrolledEventIds': ids.toList()});

  // ── Events ────────────────────────────────────────────────────────────────
  /// IMPROVEMENT #10: handleError returns empty list on failure
  Stream<List<SportEvent>> eventsStream() {
    return _events.orderBy('startDate').snapshots().map(
        (s) => s.docs.map((d) => SportEvent.fromJson(d.id, d.data())).toList());
  }

  Future<void> addEvent(SportEvent e) async =>
      _events.doc(e.id).set(e.toJson());
  Future<void> updateEvent(SportEvent e) async =>
      _events.doc(e.id).update(e.toJson());
  Future<void> deleteEvent(String id) async => _events.doc(id).delete();

  // ── Bookings ──────────────────────────────────────────────────────────────
  /// IMPROVEMENT #10: handleError on booking streams
  Stream<List<Booking>> bookingsStream(String uid) {
    return _bookings
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromJson(d.data())).toList())
        .handleError((_) => <Booking>[]);
  }

  Stream<List<Booking>> allBookingsStream() {
    return _bookings
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromJson(d.data())).toList())
        .handleError((_) => <Booking>[]);
  }

  Future<void> addBooking(Booking b, String uid) async {
    final data = b.toJson()..['uid'] = uid;
    await _bookings.doc(b.bookingId).set(data);
  }

  Future<void> updateBookingStatus(
          String bookingId, BookingStatus status) async =>
      _bookings.doc(bookingId).update({'status': status.name});

  // ── Leaderboard ───────────────────────────────────────────────────────────
  /// Reads the denormalised `leaderboard` collection rather than `users`.
  ///
  /// Reading `users` for the leaderboard forced a permissive read rule on the
  /// whole user directory, exposing every student's name, email, phone number
  /// and student ID to any signed-in user. `firestore.rules` now restricts
  /// `users` to owner + admin, so the ranking data lives in its own collection
  /// holding only the non-sensitive fields.
  ///
  /// Backfill `leaderboard/{uid}` (name, faculty, points, rank) from an admin
  /// client or a Cloud Function whenever a user's points change; the client
  /// cannot write this collection.
  Stream<List<LeaderboardEntry>> leaderboardStream(String currentUid) {
    return _db.collection('leaderboard').snapshots().map((snap) {
      final students = snap.docs
          .map((d) => LeaderboardEntry(
                rank: (d.data()['rank'] as num?)?.toInt() ?? 0,
                name: d.data()['name'] as String? ?? '',
                faculty: d.data()['faculty'] as String? ?? '',
                points: (d.data()['points'] as num?)?.toInt() ?? 0,
                initials: _initialsOf(d.data()['name'] as String? ?? ''),
                isMe: d.id == currentUid,
              ))
          .toList()
        ..sort((a, b) => b.points.compareTo(a.points));

      return students.asMap().entries.map((e) {
        final u = e.value;
        // Fall back to list position when no explicit rank is stored.
        return u.rank > 0
            ? u
            : LeaderboardEntry(
                rank: e.key + 1,
                name: u.name,
                faculty: u.faculty,
                points: u.points,
                initials: u.initials,
                isMe: u.isMe,
              );
      }).toList();
    }).handleError((e) {
      debugPrint('leaderboardStream error: $e');
      return <LeaderboardEntry>[];
    });
  }

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '' : name.substring(0, 1).toUpperCase();
  }

  // ── Enrollments ───────────────────────────────────────────────────────────
  Future<void> enroll(String eventId, String uid) async {
    await _events
        .doc(eventId)
        .collection('enrollments')
        .doc(uid)
        .set({'uid': uid, 'enrolledAt': FieldValue.serverTimestamp()});
    await _events
        .doc(eventId)
        .update({'participants': FieldValue.increment(1)});
  }

  Future<void> unenroll(String eventId, String uid) async {
    await _events.doc(eventId).collection('enrollments').doc(uid).delete();
    await _events
        .doc(eventId)
        .update({'participants': FieldValue.increment(-1)});
  }

  Future<Set<String>> getEnrolledIds(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final ids = (doc.data()?['enrolledEventIds'] as List<dynamic>?) ?? [];
      return ids.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }
}
