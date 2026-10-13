import 'dart:convert';
import 'dart:io';

import 'package:conference/pages/notification/notification_controller.dart';
import 'package:conference/pages/notification/notification_page.dart';
import 'package:conference/push_notification_manager/models/notification_model.dart';
import 'package:conference/push_notification_manager/push_notification.dart';
import 'package:conference/push_notification_manager/service/notification_handler_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Common Push Notification Coordinator (Shared cross-platform logic)
class PushNotifications {
  static FirebaseMessaging get _firebaseMessaging =>
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Request cross-platform notification permission and fetch device token
  static Future<String?> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted notification permission");
    } else {
      debugPrint("User denied notification permission");
    }

    String? token;
    if (Platform.isIOS) {
      token = await PushNotificationIOS.getToken();
    } else {
      token = await PushNotificationAndroid.getToken();
    }

    if (token != null) {
      final handlerService = Get.put(NotificationHandlerService());
      handlerService.setDeviceId = token;
      debugPrint("Device token: $token");
    }
    return token;
  }

  /// Initialize local notification plugins with Android and iOS platform configurations
  static Future<void> localNotificationInit({
    bool requestPermission = true,
  }) async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: PushNotificationAndroid.initializationSettings,
          iOS: PushNotificationIOS.initializationSettings,
        );

    if (Platform.isAndroid) {
      await PushNotificationAndroid.setupChannelAndPermission(
        _flutterLocalNotificationsPlugin,
        requestPermission: requestPermission,
      );
    }

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  /// Handles notification response when tapped by the user
  static void onNotificationTap(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      final notification = NotificationModel.fromJson(payload);

      // Add this notification in the global notification list
      notification.time ??= DateTime.now();
      NotificationModel.addNotification(notification);

      if (!Get.isRegistered<NotificationController>()) {
        Get.put(NotificationController());
      }

      await Get.to(
        () => const NotificationPage(),
        arguments: {
          'postId': notification.jobPostId,
          'isApplied': false,
          'appliedOn': null,
        },
      );
    }
  }

  /// Download a remote file and save it locally for notification rich media
  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// Display a custom local notification with Android and iOS specific builders
  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final String title =
        notification?.title ??
        data['title'] ??
        data['fullName'] ??
        'Hiringbell';
    final String body =
        notification?.body ?? data['body'] ?? data['description'] ?? '';
    final int notificationId =
        notification?.hashCode ?? message.messageId.hashCode;

    String? largeIconPath;
    String? imageUrl = "";
    if (imageUrl.isEmpty) {
      imageUrl = data['imageUrl'] ?? data['image'] ?? data['avatar'];
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String fileName = 'notification_${notificationId}_img';
        largeIconPath = await _downloadAndSaveFile(imageUrl, fileName);
      } catch (e) {
        debugPrint("Error downloading notification icon: $e");
      }
    }

    // Platform-specific configurations
    final AndroidNotificationDetails androidDetails =
        PushNotificationAndroid.buildNotificationDetails(
          title: title,
          body: body,
          largeIconPath: largeIconPath,
        );

    final DarwinNotificationDetails iosDetails =
        PushNotificationIOS.buildNotificationDetails(
          attachmentPath: largeIconPath,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final Map<String, dynamic> payloadData = Map<String, dynamic>.from(data);
    if ((payloadData['title'] == null ||
            payloadData['title'].toString().isEmpty) &&
        title.isNotEmpty) {
      payloadData['title'] = title;
    }
    if ((payloadData['description'] == null ||
            payloadData['description'].toString().isEmpty) &&
        body.isNotEmpty) {
      payloadData['description'] = body;
    }
    if ((payloadData['body'] == null ||
            payloadData['body'].toString().isEmpty) &&
        body.isNotEmpty) {
      payloadData['body'] = body;
    }
    if (!payloadData.containsKey('time')) {
      payloadData['time'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await _flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(payloadData),
    );
  }
}
