import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_models.dart';
import '../../l10n/app_localizations.dart';

enum NotifType {
  reservationReminder, registrationApproved, registrationRejected,
  upcomingEvent, formRequired, systemInfo,
}

extension NotifTypeX on NotifType {
  String get emoji => switch (this) {
    NotifType.reservationReminder  => '📅',
    NotifType.registrationApproved => '✅',
    NotifType.registrationRejected => '❌',
    NotifType.upcomingEvent        => '🏆',
    NotifType.formRequired         => '📋',
    NotifType.systemInfo           => 'ℹ️',
  };
  IconData get icon => switch (this) {
    NotifType.reservationReminder  => Icons.calendar_month_rounded,
    NotifType.registrationApproved => Icons.check_circle_rounded,
    NotifType.registrationRejected => Icons.cancel_rounded,
    NotifType.upcomingEvent        => Icons.emoji_events_rounded,
    NotifType.formRequired         => Icons.assignment_rounded,
    NotifType.systemInfo           => Icons.info_rounded,
  };
  Color get color => switch (this) {
    NotifType.reservationReminder  => const Color(0xFF00E5FF),
    NotifType.registrationApproved => const Color(0xFFA8FF3E),
    NotifType.registrationRejected => const Color(0xFFFF4757),
    NotifType.upcomingEvent        => const Color(0xFFFFB800),
    NotifType.formRequired         => const Color(0xFF7C4DFF),
    NotifType.systemInfo           => const Color(0xFF5A7090),
  };
  String label(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (this) {
      NotifType.reservationReminder  => l.notifReservationReminder,
      NotifType.registrationApproved => l.notifRegistrationApproved,
      NotifType.registrationRejected => l.notifRegistrationRejected,
      NotifType.upcomingEvent        => l.notifUpcomingEvent,
      NotifType.formRequired         => l.notifFormRequired,
      NotifType.systemInfo           => l.notifSystemInfo,
    };
  }
}

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final String? actionLabel;
  final VoidCallback? onAction;

  AppNotification({
    required this.id, required this.type, required this.title,
    required this.body, required this.time,
    this.isRead = false, this.actionLabel, this.onAction,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.name, 'title': title, 'body': body,
    'time': time.toIso8601String(), 'isRead': isRead,
    'actionLabel': actionLabel,
  };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'], type: NotifType.values.byName(j['type']),
    title: j['title'], body: j['body'],
    time: DateTime.parse(j['time']),
    isRead: j['isRead'] as bool? ?? false,
    actionLabel: j['actionLabel'] as String?,
  );
}

// ─── NOTIFICATION STATE — IMPROVEMENT #2 ─────────────────────────────────────
// Notifications are now persisted to SharedPreferences.
// Read/unread status and the notification list survive app restarts.
class NotificationState extends ChangeNotifier {
  static final NotificationState instance = NotificationState._();
  NotificationState._() { _load(); }

  static const _kKey = 'muster_notifications';
  final List<AppNotification> _notifs = [];
  bool _seeded = false;

  List<AppNotification> get all       => List.unmodifiable(_notifs);
  int  get unreadCount                => _notifs.where((n) => !n.isRead).length;

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_kKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _notifs.addAll(list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
        return;
      }
    } catch (_) {}
    if (!_seeded) { _seeded = true; _seed(); _save(); notifyListeners(); }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // onAction is a closure — don't serialize it; only store data fields
      await prefs.setString(_kKey, jsonEncode(_notifs.map((n) => n.toJson()).toList()));
    } catch (_) {}
  }

  void _seed() {
    final now = DateTime.now();
    _notifs.addAll([
      AppNotification(id:'n-01', type:NotifType.registrationApproved,  title:'Registration Approved 🎉',  body:'Your registration for ⚽ Football has been approved!',                              time:now.subtract(const Duration(hours:1))),
      AppNotification(id:'n-02', type:NotifType.reservationReminder,   title:'Reservation Reminder',       body:'You have a booking for 🎾 Padel Court 1 tomorrow at 4:00 PM.',                    time:now.subtract(const Duration(hours:3)),  actionLabel:'View Booking'),
      AppNotification(id:'n-03', type:NotifType.upcomingEvent,         title:'Event Starting Soon',         body:'🏆 MUST Padel Championship starts in 3 days. Only 8 spots left!',                 time:now.subtract(const Duration(hours:5)),  actionLabel:'View Event'),
      AppNotification(id:'n-04', type:NotifType.formRequired,          title:'Form Required',               body:'📋 Complete the Medical Clearance Form for Basketball before Mar 10.',            time:now.subtract(const Duration(hours:8)),  isRead:true, actionLabel:'Complete Form'),
      AppNotification(id:'n-05', type:NotifType.upcomingEvent,         title:'Annual Sports Day',           body:'🏅 Annual Sports Day is on Apr 20 at the Main Stadium. 100 spots remaining!',    time:now.subtract(const Duration(days:1)),   isRead:true, actionLabel:'Register'),
      AppNotification(id:'n-06', type:NotifType.reservationReminder,   title:'Upcoming Reservation',        body:'📅 Football Field A booked for this Friday at 6:00 PM. Bring your gear!',        time:now.subtract(const Duration(days:1, hours:4)), isRead:true),
      AppNotification(id:'n-07', type:NotifType.formRequired,          title:'Registration Form Pending',   body:'📋 You haven\'t submitted the form for 🎭 Acting & Theatre yet. Deadline: Mar 15.',time:now.subtract(const Duration(days:2)),   actionLabel:'Register Now'),
      AppNotification(id:'n-08', type:NotifType.registrationRejected,  title:'Registration Update',         body:'Your application for ♟️ Chess Club was not accepted this cycle.',                 time:now.subtract(const Duration(days:3)),   isRead:true),
      AppNotification(id:'n-09', type:NotifType.systemInfo,            title:'Spring 2026 Activities Open', body:'Registration for Spring 2026 is now open! Browse 24 activities.',                 time:now.subtract(const Duration(days:5)),   isRead:true, actionLabel:'Browse'),
    ]);
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void markRead(String id) {
    final i = _notifs.indexWhere((n) => n.id == id);
    if (i >= 0 && !_notifs[i].isRead) {
      _notifs[i].isRead = true;
      _save();
      notifyListeners();
    }
  }

  void markAllRead() {
    final hadUnread = _notifs.any((n) => !n.isRead);
    for (final n in _notifs) { n.isRead = true; }
    if (hadUnread) { _save(); notifyListeners(); }
  }

  void delete(String id) {
    _notifs.removeWhere((n) => n.id == id);
    _save();
    notifyListeners();
  }

  void addReservationReminder({
    required String facilityName, required String date, required String time,
  }) {
    _notifs.insert(0, AppNotification(
      id: 'n-res-${DateTime.now().millisecondsSinceEpoch}',
      type: NotifType.reservationReminder,
      title: 'Reservation Confirmed',
      body: 'Your booking for $facilityName on $date at $time is confirmed.',
      time: DateTime.now(), actionLabel: 'View Booking',
    ));
    _save(); notifyListeners();
  }

  void addRegistrationUpdate({
    required String activityName, required String activityEmoji,
    required RegistrationStatus status,
  }) {
    final approved = status == RegistrationStatus.approved;
    _notifs.insert(0, AppNotification(
      id: 'n-reg-${DateTime.now().millisecondsSinceEpoch}',
      type: approved ? NotifType.registrationApproved : NotifType.registrationRejected,
      title: approved ? 'Registration Approved 🎉' : 'Registration Not Accepted',
      body: approved
          ? 'Your registration for $activityEmoji $activityName has been approved!'
          : 'Your application for $activityEmoji $activityName was not accepted.',
      time: DateTime.now(),
    ));
    _save(); notifyListeners();
  }
}
