import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> createNormalNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: "basic_channel",
      title: '${Emojis.symbols_warning} Are you still there?',
      body: "You should respond by Checking in again.",
      wakeUpScreen: true,
    ),
  );
}















































// import 'dart:math';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter/material.dart';
// import 'package:timezone/data/latest.dart' as tz;

// class localNotificationService {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void setup() {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final DarwinInitializationSettings? initializationSettingsIos =
//         DarwinInitializationSettings(
//             requestAlertPermission: true,
//             requestSoundPermission: true,
//             requestBadgePermission: true);

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIos,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }

//   sendNatifaction(time, onDidReceiveLocalNotification) {
//     ///
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       "high channel",
//       "high import notification",
//       description: "This channel is for important natifcations",
//       importance: Importance.max,
//     );
//     flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         "Still there",
//         "body",
//         tz.TZDateTime.now(tz.UTC).add(Duration(seconds: time)),
//         NotificationDetails(
//             iOS: const DarwinNotificationDetails(
//                 presentAlert: true,
//                 presentBadge: true,
//                 presentSound: true,
//                 interruptionLevel: InterruptionLevel.critical),
//             android: AndroidNotificationDetails(channel.id, channel.name,
//                 channelDescription: channel.description)),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//             );
//   }
// }
