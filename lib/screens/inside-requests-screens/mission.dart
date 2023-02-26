// ignore_for_file: sort_child_properties_last

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({Key? key}) : super(key: key);

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController fromDateString = TextEditingController();
  TextEditingController toDateString = TextEditingController();
  TextEditingController fromDes = TextEditingController();
  TextEditingController toDes = TextEditingController();
  TextEditingController reason = TextEditingController();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
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
          backgroundColor: const Color.fromRGBO(0, 158, 247, 1),
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/nav");
            },
            icon: const Icon(FontAwesomeIcons.angleLeft),
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 60),
                  child: Text(
                    //small note it is not black
                    "mission_header".tr(),
                    style: const TextStyle(
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
              hintText: 'mission_hint'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: const BorderSide(width: 2, color: Colors.white)),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
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
              suffixIcon: const Icon(FontAwesomeIcons.calendar),
              hintText: 'from_date_label'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: const BorderSide(width: 2, color: Colors.white)),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(
                      2000), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2101));

              if (pickedDate != null) {
                // print(
                //     pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                // print(
                //     formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  fromDateString.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {
                print("Date is not selected");
              }
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
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
              suffixIcon: const Icon(FontAwesomeIcons.calendar),
              hintText: 'to_date_label'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
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
                // print(
                //     pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                // print(
                //     formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  toDateString.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {
                print("Date is not selected");
              }
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
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
              hintText: 'from_destination_label'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: const BorderSide(width: 2, color: Colors.white)),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
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
              hintText: 'to_destination_label'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: const BorderSide(width: 2, color: Colors.white)),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
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
          _validApi();
        },

        // ignore: prefer_const_constructors

        // ignore: prefer_const_constructors
        child: Text("submit_btn".tr(),
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
    var request = http.Request('POST', Uri.parse('$URL_Domin/Mission'));
    request.body = json.encode({
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
    // print(response.statusCode);
    if (response.statusCode == 200) {
      doneMessage();
    } else {
      // Fluttertoast.showToast(
      //     msg: "There is no data to Submit",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
  }

  void _validApi() async {
    if (formKey.currentState!.validate()) {
      await missionPostApi();
    } else {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
    }
  }

  void doneMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
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
                child: const Text('Go Back')),
          )
        ],
      ),
    );
  }
}
