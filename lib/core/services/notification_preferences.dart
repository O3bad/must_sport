// lib/core/services/notification_preferences.dart
// Persisted, working notification preferences.
//
// The settings screen previously held two booleans in local widget state. They
// reset on every launch and never reached Firebase, so a user who turned
// notifications off was still push-targeted — a control that lies about what it
// does. These preferences are persisted, and turning the master switch off
// revokes the FCM token (see FCMService.applyPushPreference), which actually
// stops delivery.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  NotificationPreferences._();

  static final NotificationPreferences instance = NotificationPreferences._();

  static const String _kPushEnabled = 'notif.pushEnabled';
  static const String _kEventAlerts = 'notif.eventAlerts';
  static const String _kFormAlerts = 'notif.formAlerts';

  SharedPreferences? _prefs;

  final ValueNotifier<bool> pushEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> eventAlerts = ValueNotifier<bool>(true);
  final ValueNotifier<bool> formAlerts = ValueNotifier<bool>(true);

  bool get isPushEnabled => pushEnabled.value;
  bool get showEventAlerts => eventAlerts.value;
  bool get showFormAlerts => formAlerts.value;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;
    pushEnabled.value = prefs.getBool(_kPushEnabled) ?? true;
    eventAlerts.value = prefs.getBool(_kEventAlerts) ?? true;
    formAlerts.value = prefs.getBool(_kFormAlerts) ?? true;
  }

  Future<void> setPushEnabled(bool value) async {
    pushEnabled.value = value;
    await _prefs?.setBool(_kPushEnabled, value);
  }

  Future<void> setEventAlerts(bool value) async {
    eventAlerts.value = value;
    await _prefs?.setBool(_kEventAlerts, value);
  }

  Future<void> setFormAlerts(bool value) async {
    formAlerts.value = value;
    await _prefs?.setBool(_kFormAlerts, value);
  }
}
