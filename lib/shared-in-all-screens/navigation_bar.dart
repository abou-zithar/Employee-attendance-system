import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:demo/Notification.dart';
import 'package:demo/screens/mainScreens/break.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:demo/screens/mainScreens/home.dart';
import 'package:demo/screens/mainScreens/log.dart';
import 'package:demo/screens/mainScreens/requests.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'navigation_drawer.dart';

int myIndex = 0;

class BottomBar extends StatefulWidget {
  const BottomBar({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final screens = [
    const HomeScreen(),
    const BreakScreen(),
    const RequestScreen(),
    const LogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_white.png',
          fit: BoxFit.contain,
          height: 28,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 158, 247, 1),
      ),
      drawer: const Navigation_Drawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: const Color.fromRGBO(0, 158, 247, 1),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        currentIndex: myIndex,
        //selectedIconTheme: null,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.userClock),
              label: 'clock_label'.tr()),
          BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.mugHot),
              label: 'break_label'.tr()),
          BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.calendarCheck),
              label: 'request_label'.tr()),
          BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.history),
              label: 'Log_label'.tr()),
        ],
        onTap: (value) {
          setState(() {
            AwesomeNotifications().actionSink.close();
            myIndex = value;
          });
        },
      ),
      body: screens[myIndex],
    );
  }
}
