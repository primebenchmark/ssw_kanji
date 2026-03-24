import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background/terminated notifications are displayed automatically by FCM.
}

class NotificationService {
  static const _channelId = 'ssw_kanji_high';
  static const _channelName = 'SSW Kanji Notifications';

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Show notifications while app is in foreground on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create high-importance Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Show heads-up notification when app is in foreground (Android)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Register and persist FCM token
    await _registerToken();
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {'token': token, 'updated_at': DateTime.now().toIso8601String()},
        onConflict: 'token',
      );
    } catch (_) {}
  }
}
