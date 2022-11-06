import 'package:demo/screens/break.dart';

import 'package:demo/screens/home.dart';
import 'package:demo/screens/requests.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'navigation_drawer.dart';

int myIndex = 0;

class BottomBar extends StatefulWidget {
  BottomBar({
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
        backgroundColor: Color.fromRGBO(0, 158, 247, 1),
      ),
      drawer: NavigationDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: myIndex,
        //selectedIconTheme: null,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userClock), label: 'Clock'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.mugHot), label: 'Break'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendarCheck), label: 'Requests'),
        ],
        onTap: (value) {
          setState(() {
            myIndex = value;
          });
        },
      ),
      body: screens[myIndex],
    );
  }
}
