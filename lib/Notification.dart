import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> createNormalNotification(stillThereDuration) async {
  // print(DateTime.daysPerWeek);
  final still_there_question = "still_there_question".tr();
  await AwesomeNotifications().createNotification(
    actionButtons: [
      NotificationActionButton(
          key: "Still_There", label: "still_there_btn".tr())
    ],
    content: NotificationContent(
      id: 0,
      channelKey: "Still_there_channel",
      title: '${Emojis.symbols_red_question_mark} $still_there_question',
      body: "still_there_description".tr(),
      wakeUpScreen: true,
    ),
  );
}

Future<void> createBasicNotifcation(NotificationSchedule not) async {
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      repeats: true,
      allowWhileIdle: true,
      weekday: DateTime.wednesday,
      hour: 10,
      minute: 28,
      second: 0,
      millisecond: 0,
    ),
    content: NotificationContent(
      id: 10,
      channelKey: "Basic_channel",
      title: '${Emojis.smile_alien}Check you Application',
      body: "there is an actions in your Eat app",
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
