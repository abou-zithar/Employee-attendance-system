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
      ),
      Icon(
        Icons.alarm,
        color: Colors.red,
      ),
      Icon(
        FontAwesomeIcons.mugHot,
        color: Colors.green,
      ),
      Icon(
        FontAwesomeIcons.mugHot,
        color: Colors.red,
      ),
      Icon(
        FontAwesomeIcons.question,
        color: Colors.blue,
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
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: lconsList[data["type"] - 1],
            title: Text('${stateList[data["type"] - 1]}'),
            subtitle: Text('${data["time"]}'),
            // trailing: Text("$counter"),
          ),
        ],
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
        // prefs.setString("history_of_user", data_string);

        // print(data["clocks"][0]["checkDate"].toString().split("T")[0]);
      });

      // print();
    } else {
      print(response.reasonPhrase);
    }
  }

  Widget build(BuildContext context) {
    var lastDate = "";
    if (data == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
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
                    if (data["clocks"][index]["checkDate"]
                            .toString()
                            .split("T")[0] ==
                        lastDate) {
                      return createCard(data["clocks"][index]);
                    } else {
                      lastDate = data["clocks"][index]["checkDate"]
                          .toString()
                          .split("T")[0];
                      return Column(children: [
                        Card(
                          child: Text(
                            data["clocks"][index]["checkDate"]
                                .toString()
                                .split("T")[0],
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              // shadows: [
                              //   Shadow(
                              //     blurRadius: 40.0,
                              //     color: Colors.grey,
                              //     offset: Offset(5.0, 5.0),
                              //   ),
                              // ],
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
