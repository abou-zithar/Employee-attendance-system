// ignore_for_file: file_names

import 'package:demo/screens/break.dart';
import 'package:demo/screens/excuse.dart';
import 'package:demo/screens/home.dart';
import 'package:demo/screens/mission.dart';
import 'package:demo/screens/splash.dart';
import 'package:demo/screens/vacation.dart';
import 'package:demo/shared/navigation_bar.dart';

import 'screens/login.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    if (routeSettings.name == '/break') {
      return MaterialPageRoute(builder: (_) => const BreakScreen());
    }
    if (routeSettings.name == '/nav') {
      return MaterialPageRoute(builder: (_) => BottomBar());
    }
    if (routeSettings.name == '/missions') {
      return MaterialPageRoute(builder: (_) => MissionScreen());
    }
    if (routeSettings.name == '/excuse') {
      return MaterialPageRoute(builder: (_) => ExcuseScreen());
    }
    if (routeSettings.name == '/vac') {
      return MaterialPageRoute(builder: (_) => VacationScreen());
    }
    return null;

    //return MaterialPageRoute(builder: (_) => Home());
  }
}
