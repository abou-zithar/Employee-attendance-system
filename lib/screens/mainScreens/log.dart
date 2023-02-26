import 'dart:developer';

import 'package:demo/screens/logPages/ExcuseLog.dart';
import 'package:demo/screens/logPages/missionLog.dart';
import 'package:demo/screens/logPages/vectionLog.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
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
    final lconsList = [
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
    ];

    var stateList = [
      "check_in_btn".tr(),
      "check_out_btn".tr(),
      "break_in_btn".tr(),
      "break_out_btn".tr()
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

  @override
  Widget build(BuildContext context) {
    var lastDate = "";

    // print(data);
    if (data == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            title: const TabBar(
              padding: EdgeInsets.symmetric(horizontal: 2),
              indicatorColor: const Color.fromRGBO(0, 158, 247, 1),
              splashFactory: InkSparkle.splashFactory,
              tabs: [
                Tab(
                    icon: Icon(
                  Icons.history,
                  color: Color.fromRGBO(0, 158, 247, 1),
                )),
                Tab(
                    icon: Icon(
                  FontAwesomeIcons.carSide,
                  color: Color.fromARGB(255, 3, 97, 0),
                )),
                Tab(
                    icon: Icon(
                  FontAwesomeIcons.receipt,
                  color: Color.fromARGB(255, 120, 141, 153),
                )),
                Tab(
                    icon: Icon(
                  Icons.sunny,
                  color: Color.fromARGB(255, 255, 191, 0),
                )),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(physics: BouncingScrollPhysics(), children: [
                  Container(
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
                  ),
                  Container(
                    child: MissionLogScreen(),
                  ),
                  Container(child: ExcuseLogScreen()),
                  Container(
                    child: VecationLogScreen(),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
    }
  }
}
