import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/Constants.dart';

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  @override
  String token = "";
  String userID = "";
  var data;

  void initState() {
    super.initState();
    getSharedPrefs().whenComplete(() {
      getTheLogDetails();
    });
  }

  Widget createCard(data) {
    const lconsList = [
      Icon(
        Icons.alarm,
        color: Colors.green,
        size: 40,
      ),
      Icon(
        Icons.alarm,
        color: Colors.red,
        size: 40,
      ),
      Icon(
        FontAwesomeIcons.mugHot,
        color: Colors.green,
        size: 40,
      ),
      Icon(
        FontAwesomeIcons.mugHot,
        color: Colors.red,
        size: 40,
      ),
      Icon(
        FontAwesomeIcons.question,
        color: Colors.blue,
        size: 40,
      ),
    ];

    var stateList = [
      "check_in_btn".tr(),
      "check_out_btn".tr(),
      "break_in_btn".tr(),
      "break_out_btn".tr(),
      "still_there_btn".tr(),
    ];
    var checkInID = "";
    var counter = 1;
    if (data["checkInID"] == checkInID) {
      counter += 1;
    } else {
      counter = 1;
    }

    final currentDate = data["checkDate"].toString().split("T")[0];
    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: lconsList[data["type"] - 1],
              title: Text(
                '${stateList[data["type"] - 1]}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${data["time"]}'),
              trailing: Text(
                "$currentDate",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = (prefs.getString("token") ?? "No data received");
      userID = (prefs.getString("userID") ?? "No data received");
      // print(token);
    });
  }

  getTheLogDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {'accept': '*/*', 'Authorization': "bearer $token"};
    var request = http.Request('GET', Uri.parse('$URL_Domin/log/${userID}'));

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        print(data);
        String data_string = json.encode(data["clocks"]);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Widget build(BuildContext context) {
    String getMonth(int monthNumber) {
      late String month;
      switch (monthNumber) {
        case 01:
          month = "January";
          break;
        case 02:
          month = "February";
          break;
        case 03:
          month = "March";
          break;
        case 04:
          month = "April";
          break;
        case 05:
          month = "May";
          break;
        case 06:
          month = "June";
          break;
        case 07:
          month = "July";
          break;
        case 08:
          month = "August";
          break;
        case 09:
          month = "September";
          break;
        case 10:
          month = "October";
          break;
        case 11:
          month = "November";
          break;
        case 12:
          month = "December";
          break;
      }
      return month;
    }

    dynamic lastDate = "";
    if (data == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (data["clocks"] == null) {
        return Center(
            child: Text("No Data",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40)));
      } else {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20),
                child: Text(
                  "Log_main_header".tr(),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C325E)),
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var currentDate = data["clocks"][index]["checkDate"]
                          .toString()
                          .split("T")[0];

                      var month =
                          getMonth(int.parse(currentDate.split("-")[1]));
                      print(month);
                      if (month == lastDate) {
                        return createCard(data["clocks"][index]);
                      } else {
                        lastDate = month;
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10, left: 20),
                                child: Text(
                                  "${month} ${currentDate.split("-")[0]}",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Color(0xFF1C325E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              createCard(data["clocks"][index])
                            ]);
                      }
                    },
                    itemCount: data["clocks"].length,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
