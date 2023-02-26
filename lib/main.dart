import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'App.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "basic_channel",
        channelName: "Basic Notification",
        channelDescription: "the normal natifaction ",
        importance: NotificationImportance.Max,
        defaultColor: Colors.blue,
        channelShowBadge: true)
  ]);
  // localNotificationService().setup();

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: App()));
}
