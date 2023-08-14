import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'App.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "Still_there_channel",
        channelName: "Still_there Notification",
        channelDescription: "the Still_there natifaction ",
        importance: NotificationImportance.Max,
        defaultColor: Colors.blue,
        channelShowBadge: true,
        locked: true),
    NotificationChannel(
        channelKey: "Basic_channel",
        channelName: "Basic Notification",
        channelDescription: "the normal natifaction ",
        importance: NotificationImportance.High,
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
