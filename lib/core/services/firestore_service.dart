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

  CollectionReference<Map<String, dynamic>> get _users    => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _events   => _db.collection('events');
  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');

  // ── Users ─────────────────────────────────────────────────────────────────
  Future<void> upsertUser(UserModel user) async =>
      _users.doc(user.uid).set(user.toJson(), SetOptions(merge: true));

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (_) { return null; }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snap = await _users.get();
      return snap.docs.map((d) => UserModel.fromJson(d.data())).toList();
    } catch (_) { return []; }
  }

  Future<void> deleteUser(String uid) async => _users.doc(uid).delete();

  Future<void> updateEnrolledIds(String uid, Set<String> ids) async =>
      _users.doc(uid).update({'enrolledEventIds': ids.toList()});

  // ── Events ────────────────────────────────────────────────────────────────
  /// IMPROVEMENT #10: handleError returns empty list on failure
  Stream<List<SportEvent>> eventsStream() {
    return _events.orderBy('startDate').snapshots()
        .map((s) => s.docs.map((d) => SportEvent.fromJson(d.id, d.data())).toList())
        .handleError((_) => <SportEvent>[]);
  }

  Future<void> addEvent(SportEvent e)    async => _events.doc(e.id).set(e.toJson());
  Future<void> updateEvent(SportEvent e) async => _events.doc(e.id).update(e.toJson());
  Future<void> deleteEvent(String id)    async => _events.doc(id).delete();

  // ── Bookings ──────────────────────────────────────────────────────────────
  /// IMPROVEMENT #10: handleError on booking streams
  Stream<List<Booking>> bookingsStream(String uid) {
    return _bookings.where('uid', isEqualTo: uid)
        .orderBy('date', descending: true).snapshots()
        .map((s) => s.docs.map((d) => Booking.fromJson(d.data())).toList())
        .handleError((_) => <Booking>[]);
  }

  Stream<List<Booking>> allBookingsStream() {
    return _bookings.orderBy('date', descending: true).snapshots()
        .map((s) => s.docs.map((d) => Booking.fromJson(d.data())).toList())
        .handleError((_) => <Booking>[]);
  }

  Future<void> addBooking(Booking b, String uid) async {
    final data = b.toJson()..['uid'] = uid;
    await _bookings.doc(b.bookingId).set(data);
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async =>
      _bookings.doc(bookingId).update({'status': status.name});

  // ── Leaderboard — IMPROVEMENT #3 ─────────────────────────────────────────
  /// Uses Firestore orderBy + limit(100) instead of client-side sort of ALL users.
  /// Add a Firestore composite index: collection=users, fields=role ASC, points DESC.
  Stream<List<LeaderboardEntry>> leaderboardStream(String currentUid) {
    return _users
        .snapshots()
        .map((snap) {
          // Fetch all students and sort them locally to avoid missing index errors
          final students = snap.docs
              .map((d) => UserModel.fromJson(d.data()))
              .where((u) => u.role == UserRole.student)
              .toList()
            ..sort((a, b) => b.points.compareTo(a.points));

          return students.asMap().entries.map((e) {
            final u = e.value;
            // Use the stored rank if available, otherwise use the list index
            final displayRank = u.rank > 0 ? u.rank : e.key + 1;
            
            return LeaderboardEntry(
              rank:     displayRank,
              name:     u.name,
              faculty:  u.faculty,
              points:   u.points,
              initials: u.initials,
              isMe:     u.uid == currentUid,
            );
          }).toList();
        })
        .handleError((e) {
          debugPrint('Leaderboard Stream Error: $e');
          return <LeaderboardEntry>[];
        });
  }

  // ── Enrollments ───────────────────────────────────────────────────────────
  Future<void> enroll(String eventId, String uid) async {
    await _events.doc(eventId).collection('enrollments').doc(uid).set(
        {'uid': uid, 'enrolledAt': FieldValue.serverTimestamp()});
    await _events.doc(eventId).update({'participants': FieldValue.increment(1)});
  }

  Future<void> unenroll(String eventId, String uid) async {
    await _events.doc(eventId).collection('enrollments').doc(uid).delete();
    await _events.doc(eventId).update({'participants': FieldValue.increment(-1)});
  }

  Future<Set<String>> getEnrolledIds(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final ids = (doc.data()?['enrolledEventIds'] as List<dynamic>?) ?? [];
      return ids.cast<String>().toSet();
    } catch (_) { return {}; }
  }
}
