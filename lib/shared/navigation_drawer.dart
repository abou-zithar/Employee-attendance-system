// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String? userName, email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs().whenComplete(() {});
  }

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = (prefs.getString("userName") ?? "No data received");
      email = (prefs.getString("email") ?? "No data received");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildItems(context)],
      )),
    );
  }

  buildHeader(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: Colors.blueAccent,
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/anonymous.png'),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              '$userName',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            Text(
              "$email",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildItems(BuildContext context) {
    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        // ignore: prefer_const_constructors
        ListTile(
          leading: const Icon(FontAwesomeIcons.house),
          title: const Text("Attendance"),
          onTap: () {
            //   Navigator.pushReplacementNamed(context, '/nav');
          },
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.globe),
          title: const Text("Languages"),
          onTap: () {},
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.handshakeAngle),
          title: const Text("Get Help"),
          onTap: () {},
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.circleInfo),
          title: const Text("About app"),
          onTap: () {},
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.rightFromBracket),
          title: const Text("Log out"),
          onTap: () async {
            Navigator.pushReplacementNamed(context, '/login');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("email", "");
            prefs.setString("password", "");
          },
        )
      ],
    );
  }
}
