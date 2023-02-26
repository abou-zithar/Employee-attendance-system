import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class ExcuseScreen extends StatefulWidget {
  const ExcuseScreen({Key? key}) : super(key: key);

  @override
  State<ExcuseScreen> createState() => _ExcuseScreenState();
}

class _ExcuseScreenState extends State<ExcuseScreen> {
  TextEditingController excuseReason = TextEditingController();
  TextEditingController fromDateTimeString = TextEditingController();
  TextEditingController displayDateTimeString = TextEditingController();
  TextEditingController toDateTimeString = TextEditingController();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  DateTime dateTime = DateTime.now();
  String? selectedName, displayedTime, dateTimeDisplay;
  var data = [];
  String? selectedTime, token, userID;
  int? excuseID;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    getSharedPrefs().whenComplete(() {
      excuseRequestType();
    });
    fromDateTimeString.text = '';
    toDateTimeString.text = '';

    super.initState();
  }

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = (prefs.getString("token") ?? "No data received");
      userID = (prefs.getString("userID") ?? "No data received");
    });
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
              child: Form(
        key: formKey,
        autovalidateMode: _autoValidate,
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            // ignore: prefer_const_constructors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Text(
                "excuse_header".tr(),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C325E)),
              ),
            ),
            dropDownTypes(),
            execuseField(),
            fromDate(),
            _submiteButton(),
          ],
        ),
      ))),
    );
  }

  Widget execuseField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 30, left: 30, top: 20),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: excuseReason,
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: 'excuse_hint'.tr(),
              hintStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: const BorderSide(width: 2, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget fromDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: displayDateTimeString,
            readOnly: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(FontAwesomeIcons.calendar),
              hintText: 'Excause_data/time_label'.tr(),
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
                  firstDate: DateTime
                      .now(), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2025));

              TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                initialEntryMode: TimePickerEntryMode.dial,
              );
              if (timeOfDay != null) {
                {
                  setState(() {
                    selectedTime = "${timeOfDay.hour}:${timeOfDay.minute}";
                    displayedTime = timeOfDay.format(context);
                  });
                }
              }

              if (pickedDate != null) {
                // print(pickedDate);
                //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    "${DateFormat('yyyy-MM-dd').format(pickedDate)}T${selectedTime!}";
                String displayDate =
                    "${DateFormat.yMMMMd('en_US').format(pickedDate)} ${displayedTime!}";

                // print(
                //     formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  fromDateTimeString.text = formattedDate;
                  displayDateTimeString.text =
                      displayDate; //set output date to TextField value.
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

  Widget dropDownTypes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: InputDecorator(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), fillColor: Colors.white),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedName,
              isDense: true,
              hint: Text("excuse_hint_2".tr()),
              //isExpanded: true,
              icon: const Icon(FontAwesomeIcons.angleDown, size: 24),
              elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              // underline: Container(
              //   height: 2,
              //   color: Color.fromARGB(255, 16, 9, 36),
              // ),
              onChanged: (value) {
                setState(() {
                  selectedName = value!;
                  // print(value);
                  for (int i = 0; i < data.length; i++) {
                    if (data[i]["type"] == value) {
                      excuseID = data[i]["id"];
                    }
                  }
                });
              },
              validator: (value) => value == null ? 'field required' : null,
              items: data.map((ctry) {
                return DropdownMenuItem<String>(
                    value: ctry["type"], child: Text(ctry["type"]).tr());
              }).toList(),
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
        onPressed: () {
          _validApi();
        },
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
        child: Text("submit_btn".tr(),
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  excuseRequestType() async {
    var headers = {'accept': '*/*', 'Authorization': "bearer $token"};
    var request = http.Request('GET', Uri.parse('$URL_Domin/LeaveTimeOff'));

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });

      // print();
    } else {
      print(response.reasonPhrase);
    }
  }

  excuseRequestPost() async {
    var headers = {
      'accept': '*/*',
      'Authorization': 'bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://13.79.147.127/EAT/API/api/LeaveTimeOff/RequestExcuse'));
    request.body = json.encode({
      "userID": userID,
      "exMessage": excuseReason.text.toString(),
      "excuseID": excuseID,
      "date": fromDateTimeString.text.toString()
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

  void _validApi() async {
    if (formKey.currentState!.validate()) {
      await excuseRequestPost();
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
