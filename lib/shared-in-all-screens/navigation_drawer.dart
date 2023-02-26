// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notification.dart';

class Navigation_Drawer extends StatefulWidget {
  const Navigation_Drawer({Key? key}) : super(key: key);

  @override
  State<Navigation_Drawer> createState() => _Navigation_DrawerState();
}

class _Navigation_DrawerState extends State<Navigation_Drawer> {
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

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: Text('choose_language_label'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // ignore: deprecated_member_use
                    context.setLocale(Locale('en', ''));
                    Navigator.pushReplacementNamed(context, '/nav');
                  },
                  child: Text("en".tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.setLocale(Locale('ar', ''));
                    Navigator.pushReplacementNamed(context, '/nav');
                  },
                  child: Text("ar".tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 30),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          Text(
            "$email",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  buildItems(BuildContext context) {
    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        // ignore: prefer_const_constructors
        // ListTile(
        //   leading: const Icon(FontAwesomeIcons.house),
        //   title: const Text("Attendance"),
        //   onTap: () {
        //     // Navigator.pushReplacementNamed(context, '/nav');
        //   },
        // ),

        ListTile(
          leading: const Icon(FontAwesomeIcons.globe),
          title: Text("language_label".tr()),
          onTap: _showAlertDialog,
        ),
        // const Divider(color: Colors.black54),
        // ListTile(
        //   leading: const Icon(FontAwesomeIcons.handshakeAngle),
        //   title: const Text("Get Help"),
        //   onTap: () {},
        // ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.circleInfo),
          title: Text("about_app_label".tr()),
          onTap: () {
            createNormalNotification();
            // Navigator.pushReplacementNamed(context, '/About');
          },
        ),
        const Divider(color: Colors.black54),
        // const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(FontAwesomeIcons.rightFromBracket),
          title: Text("logout_label".tr()),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final typeID = (prefs.getInt("TypeID") ?? 0);

            if (typeID == 2 || typeID == 0) {
              // print(typeID);

              Navigator.pushReplacementNamed(context, '/login');
            } else {
              Fluttertoast.showToast(
                  msg: "log_out_warring".tr(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0);

              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return AlertDialog(
              //         title: Text("log_out_warring".tr()),
              //         actions: <Widget>[
              //           TextButton(
              //               onPressed: () {
              //                 Navigator.pop(context);
              //                 // Navigator.pushReplacementNamed(context, '/nav');
              //               },
              //               child: Text('Okay_label'.tr()))
              //         ],
              //       );
              //     });
            }
            prefs.setString("email", "");
            prefs.setString("password", "");
          },
        )
      ],
    );
  }
}
