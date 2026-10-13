import 'dart:convert';
import 'package:get/get.dart';

typedef PushNotificationModel = NotificationModel;
typedef PushnotificationModel = NotificationModel;

class NotificationModel {
  static final RxList<NotificationModel> globalNotifications =
      <NotificationModel>[].obs;

  static void addNotification(NotificationModel notification) {
    notification.time ??= DateTime.now();

    final int index = globalNotifications.indexWhere((item) {
      if (notification.jobPostId != 0 && item.jobPostId != 0) {
        return item.jobPostId == notification.jobPostId;
      }
      if (notification.title != null &&
          notification.title!.isNotEmpty &&
          notification.title == item.title &&
          notification.description == item.description) {
        return true;
      }
      return false;
    });

    if (index != -1) {
      final existing = globalNotifications.removeAt(index);
      notification.isRead = existing.isRead;
      globalNotifications.insert(0, notification);
    } else {
      globalNotifications.insert(0, notification);
    }
    globalNotifications.refresh();
  }

  int rowIndex;
  int followerId; // subscriber - who subscribed my channel
  int followedId; // to whome I am following
  int jobPostId;
  String? imageUrl;
  String? email;
  String? title;
  String? description;
  String? fullName;
  String? deviceId;
  DateTime? time;
  String? notificationType;
  bool isRead;

  NotificationModel({
    this.rowIndex = 0,
    this.followerId = 0,
    this.followedId = 0,
    this.jobPostId = 0,
    this.imageUrl,
    this.email,
    this.title,
    this.description,
    this.fullName,
    this.deviceId,
    this.time,
    this.notificationType,
    this.isRead = false,
  });

  factory NotificationModel.noArgs() {
    return NotificationModel(
      rowIndex: 0,
      followerId: 0,
      followedId: 0,
      jobPostId: 0,
    );
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static String? _toString(dynamic val) {
    if (val == null) return null;
    return val.toString();
  }

  static DateTime? _parseTime(dynamic val) {
    if (val == null) return null;
    final ms = int.tryParse(val.toString());
    if (ms != null) {
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

  static Map<String, dynamic> _parsePayloadString(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {}

    final Map<String, dynamic> result = {};
    String clean = payload.trim();
    if (clean.startsWith('{') && clean.endsWith('}')) {
      clean = clean.substring(1, clean.length - 1);
    }

    final keys = [
      'rowIndex',
      'followerId',
      'followedId',
      'jobPostId',
      'imageUrl',
      'email',
      'title',
      'description',
      'fullName',
      'deviceId',
      'time',
      'notificationType'
    ];

    final List<MapEntry<String, int>> positions = [];
    for (final key in keys) {
      int idx = clean.indexOf('$key: ');
      if (idx == -1) {
        idx = clean.indexOf('$key:');
      }
      if (idx != -1) {
        positions.add(MapEntry(key, idx));
      }
    }

    positions.sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < positions.length; i++) {
      final currentKey = positions[i].key;
      final startIdx = positions[i].value + currentKey.length + 2;
      final endIdx = (i + 1 < positions.length) ? positions[i + 1].value : clean.length;

      String val = clean.substring(startIdx, endIdx).trim();
      if (val.endsWith(',')) {
        val = val.substring(0, val.length - 1).trim();
      }
      result[currentKey] = val;
    }
    return result;
  }

  factory NotificationModel.fromJson(dynamic json) {
    if (json == null) return NotificationModel.noArgs();

    Map<String, dynamic> jsonMap;
    if (json is Map<String, dynamic>) {
      jsonMap = json;
    } else if (json is Map) {
      jsonMap = json.cast<String, dynamic>();
    } else if (json is String) {
      jsonMap = _parsePayloadString(json);
    } else {
      return NotificationModel.noArgs();
    }

    return NotificationModel(
      rowIndex: _toInt(jsonMap['rowIndex']),
      followerId: _toInt(jsonMap['followerId']),
      followedId: _toInt(jsonMap['followedId']),
      jobPostId: _toInt(jsonMap['jobPostId'] ?? jsonMap['postId']),
      imageUrl: _toString(jsonMap['imageUrl'] ?? jsonMap['imageURL'] ?? jsonMap['profileImage']),
      email: _toString(jsonMap['email']),
      title: _toString(jsonMap['title']),
      description: _toString(jsonMap['description'] ?? jsonMap['body']),
      fullName: _toString(jsonMap['fullName']),
      deviceId: _toString(jsonMap['deviceId']),
      time: _parseTime(jsonMap['time']),
      notificationType: _toString(jsonMap['notificationType']),
      isRead: jsonMap['isRead'] == true || jsonMap['isRead'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rowIndex': rowIndex,
      'followerId': followerId,
      'followedId': followedId,
      'jobPostId': jobPostId,
      'imageUrl': imageUrl,
      'email': email,
      'title': title,
      'description': description,
      'fullName': fullName,
      'deviceId': deviceId,
      'time': time?.millisecondsSinceEpoch.toString(),
      'notificationType': notificationType,
      'isRead': isRead,
    };
  }
}
