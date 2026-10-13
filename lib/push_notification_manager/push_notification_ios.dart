import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// iOS / Darwin-specific Push Notification Configuration
class PushNotificationIOS {
  /// Darwin/iOS initialization settings for local notifications
  static const DarwinInitializationSettings initializationSettings =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  /// Build iOS-specific notification details with optional attachment
  static DarwinNotificationDetails buildNotificationDetails({
    String? attachmentPath,
  }) {
    return DarwinNotificationDetails(
      attachments: attachmentPath != null
          ? [DarwinNotificationAttachment(attachmentPath)]
          : null,
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
  }

  /// Retrieve iOS APNS device token
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getAPNSToken();
  }
}
