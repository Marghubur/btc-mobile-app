import 'package:conference/push_notification_manager/push_notification.dart';
import 'package:conference/push_notification_manager/push_notification_snack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  // If message.notification != null, Android/iOS OS and FCM SDK automatically display it.
  // Only trigger manual local notification if this is a data-only payload (message.notification == null).
  if (message.notification == null && message.data.isNotEmpty) {
    debugPrint("Handling data-only background message: ${message.messageId}");
    await PushNotifications.localNotificationInit(requestPermission: false);
    await PushNotifications.showNotification(message);
  } else {
    debugPrint(
        "Background notification received (handled by OS): ${message.notification?.title}");
  }
}

class PushNotificationInit {
  static void showTopNotification(
    RemoteNotification? notification,
    Map<String, dynamic> data,
  ) {
    if (notification == null) return;
    showOverlayNotification(
      (context) {
        return PushNotificationSnack(
          message: data,
          remoteNotification: notification,
        );
      },
      duration: const Duration(seconds: 10),
    );
  }

  /// Single static method to initialize Firebase and complete all Push Notification configurations
  static Future<String?> init() async {
    String? token;
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } on FirebaseException catch (e) {
          if (e.code == 'duplicate-app') {
            debugPrint("Firebase default app already initialized natively.");
          } else {
            try {
              await Firebase.initializeApp();
            } catch (_) {
              rethrow;
            }
          }
        } catch (e) {
          if (e.toString().contains('duplicate-app')) {
            debugPrint("Firebase default app already initialized natively.");
          } else {
            rethrow;
          }
        }
      }

      // init push notification
      token = await PushNotifications.init();

      // init local notification
      await PushNotifications.localNotificationInit();

      // Listen to background notification
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

      // Listen to foreground notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Got a message on foreground");
        if (message.notification != null) {
          showTopNotification(message.notification, message.data);
        }
      });
    } catch (e, stack) {
      debugPrint("Firebase/Push Notification initialization failed: $e\n$stack");
    }
    return token;
  }
}
