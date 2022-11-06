// ignore_for_file: use_build_context_synchronously, annotate_overrides, prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String finalEmail = "";
String finalPassword = "";

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(minutes: 59), (Timer t) => _authAPI());
    _authAPI();

    getValidationData().whenComplete(() async {
      _navToHome();
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        //add more permission to request here.
      ].request();

      if (statuses[Permission.location]!.isDenied) {
        //check each permission status after.
        print("Location permission is denied.");
      }

      if (statuses[Permission.camera]!.isDenied) {
        //check each permission status after.
        print("Camera permission is denied.");
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 33, 107, 243),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Image(
                image: AssetImage('assets/images/logo_white.png'),
                height: 150,
                width: 150,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "Employee Tracking Application",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(
                height: 30,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            ],
          ),
        ));
  }

  void _navToHome() async {
    await Future.delayed(const Duration(milliseconds: 5000), () {});
    if (finalEmail.isNotEmpty && finalPassword.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/nav');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future getValidationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var optainedEmail = prefs.getString("email") ?? "";
    var optainedPassword = prefs.getString("password") ?? "";
    setState(() {
      finalEmail = optainedEmail;
      finalPassword = optainedPassword;
    });
    print(finalEmail + " " + finalPassword);
  }

  _authAPI() async {
    var headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('http://13.79.147.127/EAT/API/api/Authenticate/GetToken'));
    request.body = json.encode({
      "clientID": "Eat_Client",
      "key": "zg/sl5QzGQD0CivStTW1Yfe66d6TgY3tbz/sm/q46c4="
    });
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final decodedMap = json.decode(response.body);
    print(decodedMap['token']);

    if (response.statusCode == 200) {
      print(decodedMap['token']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", decodedMap['token']);
    } else {
      print(response.reasonPhrase);
    }
  }
}
