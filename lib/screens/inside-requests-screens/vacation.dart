// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class VacationScreen extends StatefulWidget {
  const VacationScreen({Key? key}) : super(key: key);

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  TextEditingController excuseReason = TextEditingController();
  TextEditingController fromDateTimeString = TextEditingController();
  TextEditingController displayDateTimeString = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController toDateString = TextEditingController();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  DateTime dateTime = DateTime.now();
  DateTime? _selectedDate;
  String? selectedName, displayedTime, dateTimeDisplay;
  var data = [];
  String? selectedTime, token, userID;
  int? vacID, balance;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    balance = 0;
    getSharedPrefs().whenComplete(() {
      vacGetRequest();
    });

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
    final balance_label = "Balance_label".tr();
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
            Padding(
              padding: EdgeInsets.only(top: 50, bottom: 60),
              child: Text(
                "vacation_header".tr(),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C325E)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, bottom: 10),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("$balance_label $balance")),
            ),
            dropDownTypes(),
            fromDate(),
            todate(),
            _submiteButton()
          ],
        ),
      ))),
    );
  }

  void _validApi() async {
    if (formKey.currentState!.validate()) {
      await vacPostRequest();
    } else {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
    }
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
              iconSize: 20,
              elevation: 50,
              itemHeight: null,
              isExpanded: true,
              value: selectedName,
              isDense: true,
              hint: Text("vacation_hint".tr()),

              //isExpanded: true,
              icon: const Icon(FontAwesomeIcons.angleDown, size: 24),

              style: const TextStyle(color: Colors.black, fontSize: 16),
              // underline: Container(
              //   height: 2,
              //   color: Color.fromARGB(255, 16, 9, 36),
              // ),
              onChanged: (value) {
                setState(() {
                  selectedName = value!;

                  for (int i = 0; i < data.length; i++) {
                    if (data[i]["type"] == value) {
                      vacID = data[i]["id"];
                      setState(() {
                        balance = data[i]['remaining'];
                      });
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
            decoration: InputDecoration(
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              hintText: 'from_date_label'.tr(),
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
                  firstDate: DateTime
                      .now(), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2025));

              if (pickedDate != null) {
                _selectedDate = pickedDate;
                //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                String displayDate =
                    DateFormat.yMMMMd('en_US').format(pickedDate);

                setState(() {
                  fromDateTimeString.text = formattedDate;
                  displayDateTimeString.text =
                      displayDate; //set output date to TextField value.
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

  Widget todate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Center(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: TextFormField(
            controller: toDate,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              hintText: 'to_date_label'.tr(),
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 2, color: Colors.white)),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field can\'t be empty.';
              } else {
                return null;
              }
            },
            onTap: () async {
              _validApi();
              if (_selectedDate != null) {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate!,
                    firstDate:
                        _selectedDate!, //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2025));

                if (pickedDate != null) {
                  // print(pickedDate);
                  //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  String displayDate =
                      DateFormat.yMMMMd('en_US').format(pickedDate);

                  // print(
                  //     formattedDate); //formatted date output using intl package =>  2021-03-16
                  // //you can implement different kind of Date Format here according to your requirement

                  setState(() {
                    toDateString.text = formattedDate;
                    toDate.text =
                        displayDate; //set output date to TextField value.
                  });
                } else {
                  print("Date is not selected");
                }
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
        onPressed: () {
          _validApi();
        },
        // ignore: sort_child_properties_last
        child: Text("submit_btn".tr(),
            style: TextStyle(
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

  vacGetRequest() async {
    //!problem at the api need to change the url
    var headers = {'accept': '*/*', 'Authorization': 'bearer $token'};
    var request =
        http.Request('GET', Uri.parse('$URL_Domin/LeaveTimeOff/$userID'));

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  vacPostRequest() async {
    var headers = {
      'accept': '*/*',
      'Authorization': 'bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('http://13.79.147.127/EAT/API/api/LeaveTimeOff'));
    request.body = json.encode({
      "userID": userID,
      "vacationID": vacID,
      "from": fromDateTimeString.text.toString(),
      "to": toDateString.text.toString()
    });
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decodedMap = json.decode(response.body);
      doneMessage();
      print(decodedMap);
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
                child: Text('ok')),
          )
        ],
      ),
    );
  }
}
