// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  // render
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  String _token = "";
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // create instance from Provider Type.
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.fill)),
        child: Container(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: _autoValidate,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/images/logo.png',
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  _emailField(),
                  SizedBox(height: 10),
                  _passwordField(),
                  _button()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        color: Colors.white,
        child: TextFormField(
          controller: emailController,
          style: TextStyle(fontSize: 18.0, color: Colors.black),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.mail)),
          // ignore: missing_return
          validator: (value) {
            if (value!.isEmpty) {
              return 'This field can\'t be empty.';
            } else if (!RegExp(
                    r"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$")
                .hasMatch(value)) {
              return 'Enter correct Email';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  Widget _passwordField() {
    // ignore: prefer_const_constructors
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: TextFormField(
            controller: passwordController,
            style: TextStyle(fontSize: 18.0, color: Colors.black),
            keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            }),
      ),
    );
  }

  Widget _button() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          _validApi();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(0, 158, 247, 1),
              Color.fromRGBO(114, 57, 234, 1)
            ]),
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: const Text(
              'Login',
              // ignore: unnecessary_const
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Segoe UI',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _validApi() async {
    if (formKey.currentState!.validate()) {
      validationRequest();
    } else {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
    }
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _token = (prefs.getString("token") ?? "No data received");
    });
  }

  validationRequest() async {
    print(_token);
    var headers = {
      'accept': '*/*',
      'Authorization': "bearer $_token",
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST',
        Uri.parse('http://13.79.147.127/EAT/API/api/Authenticate/Login'));
    request.body = json.encode({
      "userName": emailController.text,
      "password": passwordController.text
    });
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    //final decodedMap = json.decode(response.body);

    if (response.statusCode == 200) {
      //print(await response.stream.bytesToString());
      final decodedMap = json.decode(response.body);
      if (decodedMap['error'] == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", emailController.text);
        prefs.setString("password", passwordController.text);
        prefs.setString("userID", decodedMap['userID']);
        prefs.setString("userName", decodedMap['name']);
        Navigator.pushReplacementNamed(context, '/nav');
      } else {
        Fluttertoast.showToast(
          msg: "This user is not registered",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      print("error");
    }
  }
}
