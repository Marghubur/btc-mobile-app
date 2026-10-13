import 'package:conference/push_notification_manager/service/notification_handler_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'core/storage/storage.dart';
import 'services/http_service.dart';
import 'services/meeting_service.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/splash_controller.dart';
import 'pages/team/team_controller.dart';
import 'pages/team/service/chat_service.dart';
import 'pages/team/chat_detail_controller.dart';
import 'pages/team/chat_detail_page.dart';
import 'pages/meet/meet_controller.dart';
import 'pages/meet/sub_pages/schedule_meeting/schedule_meeting_controller.dart';
import 'pages/meet/sub_pages/schedule_meeting/schedule_meeting_page.dart';
import 'pages/calendar/calendar_controller.dart';
import 'pages/calendar/calendar_page.dart';
import 'pages/notification/notification_controller.dart';
import 'pages/notification/notification_page.dart';
import 'pages/profile/profile_controller.dart';
import 'pages/profile/profile_page.dart';
import 'pages/search/team_search_controller.dart';
import 'pages/search/team_search_page.dart';
import 'pages/login/login_controller.dart';
import 'pages/login/login_page.dart';
import 'pages/main/main_controller.dart';
import 'pages/main/main_page.dart';
import 'pages/privacy_policy/privacy_policy_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_service.dart';
import 'widgets/meeting_overlay_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create shared preferences and load configuration
  SharedPreferences? pref;
  try {
    await AppConfig.initialize();
    pref = await SharedPreferences.getInstance();
  } catch (e, stack) {
    debugPrint("Failed to load app config or shared preferences: $e\n$stack");
  }

  await StorageService.instance.initialize();
  await ChatStorage.instance.initialize();
  await HttpService.instance.initialize();

  // Register Notification handler service
  var handler = Get.put(NotificationHandlerService(), permanent: true);

  // Register Notification handler service
  Get.put(NotificationController(), permanent: true);

  // Register MeetingService as a permanent GetxService
  Get.put(MeetingService(), permanent: true);

  // Register ChatService as a permanent GetxService
  Get.put(ChatService(), permanent: true);

  // Register ThemeService
  Get.put(ThemeService(), permanent: true);

  runApp(
    OverlaySupport.global(
      child: MyApp(
        pref: pref,
      ),
    ),
  );

  await handler.initNotificationConfigure();
}

class MyApp extends StatelessWidget {
  final SharedPreferences? pref;

  const MyApp({super.key, this.pref});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Confeet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeService.instance.themeMode,
        initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashPage(),
          binding: BindingsBuilder(() {
            Get.put(SplashController());
          }),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LoginController());
          }),
        ),
        GetPage(
          name: '/privacy-policy',
          page: () => const PrivacyPolicyPage(),
        ),
        GetPage(
          name: '/main',
          page: () => const MainPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => MainController());
            Get.lazyPut(() => TeamController());
            Get.lazyPut(() => MeetController());
            Get.lazyPut(() => CalendarController());
          }),
        ),
        GetPage(
          name: '/chat-detail',
          page: () => const ChatDetailPage(),
          binding: BindingsBuilder(() {
            // MainController needed for desktop side menu
            if (!Get.isRegistered<MainController>()) {
              Get.lazyPut(() => MainController());
            }
            Get.lazyPut(() => ChatDetailController());
          }),
        ),
        GetPage(
          name: '/schedule-meeting',
          page: () => const ScheduleMeetingPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => ScheduleMeetingController());
          }),
        ),
        GetPage(
          name: '/meet-calendar',
          page: () => const CalendarPage(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<CalendarController>()) {
              Get.lazyPut(() => CalendarController());
            }
          }),
        ),
        GetPage(
          name: '/calendar',
          page: () => const CalendarPage(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<CalendarController>()) {
              Get.lazyPut(() => CalendarController());
            }
          }),
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => NotificationController());
          }),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => ProfileController());
          }),
        ),
        GetPage(
          name: '/search',
          page: () => const TeamSearchPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => TeamSearchController());
          }),
        ),
      ],
      // Wrap entire app with the overlay manager
      builder: (context, child) {
        return MeetingOverlayManager(child: child ?? const SizedBox.shrink());
      },
    ),);
  }
}
