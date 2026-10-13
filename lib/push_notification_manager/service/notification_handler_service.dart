import 'package:conference/push_notification_manager/push_notification_init.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationHandlerService {
  String? _deviceId;

  String? get deviceId => _deviceId;

  set setDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  String getPostedTime(DateTime dateTime) {
    DateTime localDateTime = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    ).toLocal();

    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "${months}mo";
    } else {
      final years = (difference.inDays / 365).floor();
      return "${years}y";
    }
  }

  void setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> initNotificationConfigure() async {
    // Initialize Firebase and complete all push notification configurations
    await PushNotificationInit.init();
  }
}