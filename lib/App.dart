// ignore_for_file: file_names

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:demo/screens/aboutUS.dart';
import 'package:demo/screens/logPages/ExcuseLog.dart';
import 'package:demo/screens/logPages/missionLog.dart';
import 'package:demo/screens/logPages/vectionLog.dart';
import 'package:demo/screens/mainScreens/break.dart';
import 'package:demo/screens/inside-requests-screens/excuse.dart';
import 'package:demo/screens/mainScreens/home.dart';
import 'package:demo/screens/inside-requests-screens/mission.dart';
import 'package:demo/screens/mainScreens/log.dart';
import 'package:demo/screens/splash.dart';
import 'package:demo/screens/inside-requests-screens/vacation.dart';
import 'package:demo/shared-in-all-screens/navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/login.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Eat',
      initialRoute: '/splash_screen',
      onGenerateRoute: onGenerateRoute,
    );
  }

  Route? onGenerateRoute(RouteSettings routeSettings) {
    if (routeSettings.name == '/login') {
      return MaterialPageRoute(builder: (_) => Login());
    }
    if (routeSettings.name == '/splash_screen') {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
    if (routeSettings.name == '/home') {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
    if (routeSettings.name == '/ExcuseLog') {
      return MaterialPageRoute(builder: (_) => const ExcuseLogScreen());
    }
    if (routeSettings.name == '/MissionLog') {
      return MaterialPageRoute(builder: (_) => const MissionLogScreen());
    }

    if (routeSettings.name == '/break') {
      return MaterialPageRoute(builder: (_) => const BreakScreen());
    }
    if (routeSettings.name == '/nav') {
      return MaterialPageRoute(builder: (_) => const BottomBar());
    }
    if (routeSettings.name == '/missions') {
      return MaterialPageRoute(builder: (_) => const MissionScreen());
    }
    if (routeSettings.name == '/excuse') {
      return MaterialPageRoute(builder: (_) => const ExcuseScreen());
    }
    if (routeSettings.name == '/Log') {
      return MaterialPageRoute(builder: (_) => const LogScreen());
    }
    if (routeSettings.name == '/vac') {
      return MaterialPageRoute(builder: (_) => const VacationScreen());
    }
    if (routeSettings.name == '/vacLog') {
      return MaterialPageRoute(builder: (_) => const VecationLogScreen());
    }
    if (routeSettings.name == '/About') {
      return MaterialPageRoute(builder: (_) => const AboutUsPage());
    }
    return null;

    //return MaterialPageRoute(builder: (_) => Home());
  }
}
