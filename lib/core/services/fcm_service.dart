// lib/core/services/fcm_service.dart
import 'dart:developer' as dev;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background FCM messages here
  dev.log('Background message: ${message.messageId}', name: 'FCMService');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'must_activities_channel',
    'MUST Activities Notifications',
    description: 'Notifications for MUST Activities app',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Setup local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTap(response);
      },
    );

    // Create Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check initial message (app opened from terminated via notification)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Save FCM token
    await _saveFCMToken();

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> _saveFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await _fcm.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    await _saveFCMToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'MUST Activities',
      body: notification.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          color: DarkColors.primary,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route']?.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final route = message.data['route'];
    // Navigation would be handled here based on route
    dev.log('Notification tapped, route: $route', name: 'FCMService');
  }

  void _onNotificationTap(NotificationResponse response) {
    final route = response.payload;
    dev.log('Local notification tapped, route: $route', name: 'FCMService');
  }

  /// Subscribe to a topic (e.g., role-based)
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  /// Get FCM token
  Future<String?> getToken() => _fcm.getToken();

  /// Delete token (on logout)
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .update({'fcmToken': FieldValue.delete()});
    }
  }
}

// ============================================================
// CLOUD FUNCTIONS (deploy to Firebase for real FCM push):
// Save this as functions/index.js in your Firebase project
// ============================================================
/*
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger: when a notification doc is created in Firestore
exports.sendPushNotification = functions.firestore
  .document("notifications/{notifId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { title, body, targetRole } = data;

    let tokens = [];

    if (targetRole) {
      // Get tokens for specific role
      const usersSnap = await admin.firestore()
        .collection("users")
        .where("role", "==", targetRole)
        .where("isActive", "==", true)
        .get();
      tokens = usersSnap.docs
        .map(doc => doc.data().fcmToken)
        .filter(Boolean);
    } else {
      // Send to all users
      const usersSnap = await admin.firestore()
        .collection("users")
        .where("isActive", "==", true)
        .get();
      tokens = usersSnap.docs
        .map(doc => doc.data().fcmToken)
        .filter(Boolean);
    }

    if (tokens.length === 0) return null;

    const payload = {
      notification: { title, body },
      data: { route: "/notifications" },
    };

    // Send in batches of 500 (FCM limit)
    const chunks = [];
    for (let i = 0; i < tokens.length; i += 500) {
      chunks.push(tokens.slice(i, i + 500));
    }

    const results = await Promise.all(
      chunks.map(chunk =>
        admin.messaging().sendEachForMulticast({
          tokens: chunk,
          ...payload,
        })
      )
    );

    console.log("FCM results:", JSON.stringify(results));
    return null;
  });

// Trigger: when a new session is created, notify enrolled students
exports.notifyNewSession = functions.firestore
  .document("sessions/{sessionId}")
  .onCreate(async (snap, context) => {
    const session = snap.data();
    const activitySnap = await admin.firestore()
      .collection("activities")
      .doc(session.activityId)
      .get();

    const activity = activitySnap.data();
    const enrolledIds = activity.enrolledStudentIds || [];

    const tokens = [];
    for (const uid of enrolledIds) {
      const userSnap = await admin.firestore()
        .collection("users").doc(uid).get();
      const token = userSnap.data()?.fcmToken;
      if (token) tokens.push(token);
    }

    if (tokens.length === 0) return null;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "New Session Scheduled! 📅",
        body: `A new session for ${session.activityName} has been scheduled.`,
      },
      data: { route: "/sessions" },
    });

    return null;
  });
*/
