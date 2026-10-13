import 'package:conference/pages/common/image_viewer/widget/file_loader.dart';
import 'package:conference/pages/notification/notification_controller.dart';
import 'package:conference/pages/notification/notification_page.dart';
import 'package:conference/push_notification_manager/models/notification_model.dart';
import 'package:conference/push_notification_manager/service/notification_handler_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';

class PushNotificationSnack extends StatelessWidget {
  final Map<String, dynamic> message;
  final RemoteNotification remoteNotification;

  const PushNotificationSnack({
    super.key,
    required this.message,
    required this.remoteNotification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final notification = NotificationModel.fromJson(message);
    final handlerService = Get.put(NotificationHandlerService());

    return SafeArea(
      child: SlideDismissible(
        key: ValueKey(remoteNotification.hashCode),
        direction: DismissDirection.up,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.03),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  OverlaySupportEntry.of(context)?.dismiss(animate: true);
                  try {
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
                  } catch (e) {
                    debugPrint(
                      "Failed to navigate from snack notification: $e",
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Poster/Banner Header (if available)
                    if (notification.imageUrl != null &&
                        notification.imageUrl!.isNotEmpty)
                      Stack(
                        children: [
                          Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                            child: _bindNotificationWall(notification),
                          ),
                          // Subtle dark gradient overlay on banner for readability
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          // App Info overlay on Poster
                          Positioned(
                            top: 8,
                            left: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/blue_collar_icon.png',
                                    width: 16,
                                    height: 16,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.notifications,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  notification.fullName ??
                                      "Confeet notification",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  notification.time != null
                                      ? handlerService.getPostedTime(
                                          notification.time!,
                                        )
                                      : "now",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dismiss button on Poster
                          Positioned(
                            top: 6,
                            right: 8,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                OverlaySupportEntry.of(
                                  context,
                                )?.dismiss(animate: true);
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      // Standard Header Bar (if no poster)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          top: 10.0,
                          bottom: 4.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/blue_collar_icon.png',
                                width: 14,
                                height: 14,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.notifications_active_outlined,
                                      color: primaryColor,
                                      size: 14,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "HIRINGBELL",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "now",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () {
                                OverlaySupportEntry.of(
                                  context,
                                )?.dismiss(animate: true);
                              },
                            ),
                          ],
                        ),
                      ),

                    // 2. Notification Body
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        right: 12.0,
                        top: 8.0,
                        bottom: 12.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: Avatar (if any) or Type-specific Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withValues(alpha: 0.05),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child:
                                  notification.imageUrl != null &&
                                      notification.imageUrl!.isNotEmpty
                                  ? _getUserProfileImage(notification.imageUrl!)
                                  : _buildPlaceholderIcon(primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content: Title & Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  remoteNotification.title ?? "New Update",
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  remoteNotification.body ?? "",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(Color primaryColor) {
    final hasPostId = message["postId"] != null;
    return Icon(
      hasPostId
          ? Icons.chat_bubble_outline_rounded
          : Icons.notifications_none_rounded,
      color: primaryColor,
      size: 20,
    );
  }

  Widget _getUserProfileImage(String url) {
    return FileLoader.loadImage(fileUrl: url);
  }

  Widget _bindNotificationWall(NotificationModel notification) {
    return FileLoader.loadImage(fileUrl: notification.imageUrl);
  }
}
