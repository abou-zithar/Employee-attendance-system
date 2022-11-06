// ignore_for_file: sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  TextEditingController fromDateString = TextEditingController();
  TextEditingController toDateString = TextEditingController();
  TextEditingController fromDes = TextEditingController();
  TextEditingController toDes = TextEditingController();
  TextEditingController reason = TextEditingController();
  String? token, userID;
  @override
  void initState() {
    getSharedPrefs().whenComplete(() {});
    fromDateString.text = '';
    toDateString.text = '';
    fromDes.text = '';
    toDes.text = '';
    reason.text = '';
    super.initState();
  }

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
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/nav");
            },
            icon: Icon(FontAwesomeIcons.angleLeft),
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50, bottom: 60),
                child: Text(
                  "Missions Request",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C325E)),
                ),
              ),
              missionField(),
              fromDate(),
              toDate(),
              fromDestination(),
              toDestination(),
              _submiteButton()
            ],
          ),
        ),
      ),
    );
  }

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = (prefs.getString("token") ?? "No data received");
      userID = (prefs.getString("userID") ?? "No data received");
    });
  }

  Widget missionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: reason,
            decoration: InputDecoration(
              hintText: 'write your mission',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget fromDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: fromDateString,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              hintText: 'From date',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(
                      2000), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2101));

              if (pickedDate != null) {
                print(
                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                print(
                    formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  fromDateString.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {
                print("Date is not selected");
              }
            },
          ),
        ),
      ),
    );
  }

  Widget toDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: toDateString,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              hintText: 'To date',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(
                      2000), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2101));

              if (pickedDate != null) {
                print(
                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                print(
                    formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  toDateString.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {
                print("Date is not selected");
              }
            },
          ),
        ),
      ),
    );
  }

  Widget fromDestination() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: fromDes,
            decoration: InputDecoration(
              hintText: 'From Destination',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget toDestination() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: toDes,
            decoration: InputDecoration(
              hintText: 'To Destination',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submiteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          await missionPostApi();
        },

        // ignore: prefer_const_constructors

        // ignore: prefer_const_constructors
        child: Text("Submit",
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
      ),
    );
  }

  missionPostApi() async {
    var headers = {
      'accept': '*/*',
      'Authorization': 'bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('http://13.79.147.127/EAT/API/api/Mission'));
    request.body = json.encode({
      // "message": reason.text,
      // "userId": userID,
      // "startTime": fromDateString.text,
      // "endTime": toDateString.text,
      // "from_Location": fromDes.text,
      // "to_Location": toDes.text
      "message": reason.text,
      "date": fromDateString.text,
      "userId": userID,

      "startTime": fromDateString.text,
      "endTime": toDateString.text,
      "from_Location": fromDes.text,
      "to_Location": toDes.text
    });
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      doneMessage();
    } else {
      print(response.reasonPhrase);
    }
  }

  void doneMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'Done',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, "/nav");
                },
                child: Text('Go Back')),
          )
        ],
      ),
    );
  }
}
