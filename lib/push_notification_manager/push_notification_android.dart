import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android-specific Push Notification Configuration
class PushNotificationAndroid {
  static const String channelId = 'confeet_notification_channel';
  static const String channelName = 'Confeet Notifications';
  static const String channelDescription =
      'This channel is used for confeet app notifications.';
  static const String iconResource = '@mipmap/ic_launcher';
  static const String largeIconResource = '@mipmap/ic_launcher';
  static const Color accentColor = Color(0xFF2B3B7D);

  /// Android initialization settings for local notifications
  static const AndroidInitializationSettings initializationSettings =
      AndroidInitializationSettings(iconResource);

  /// Default notification channel for Android 8.0+ (API 26+)
  static const AndroidNotificationChannel notificationChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Setup the notification channel and request permission if needed
  static Future<void> setupChannelAndPermission(
    FlutterLocalNotificationsPlugin plugin, {
    bool requestPermission = true,
  }) async {
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (requestPermission) {
      await androidPlugin?.requestNotificationsPermission();
    }

    await androidPlugin?.createNotificationChannel(notificationChannel);
  }

  /// Build Android-specific notification details
  static AndroidNotificationDetails buildNotificationDetails({
    required String title,
    required String body,
    String? largeIconPath,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: iconResource,
      color: accentColor,
      largeIcon: largeIconPath != null
          ? FilePathAndroidBitmap(largeIconPath)
          : const DrawableResourceAndroidBitmap(largeIconResource),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      ),
    );
  }

  /// Retrieve Android FCM device token
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
