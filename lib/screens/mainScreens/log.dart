import 'package:demo/screens/logPages/ExcuseLog.dart';
import 'package:demo/screens/logPages/attendance.dart';
import 'package:demo/screens/logPages/missionLog.dart';
import 'package:demo/screens/logPages/vectionLog.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
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
      Icon(
        FontAwesomeIcons.question,
        color: Colors.red,
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
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            title: TabBar(
              padding: EdgeInsets.symmetric(horizontal: 2),
              indicatorColor: const Color.fromRGBO(0, 158, 247, 1),
              splashFactory: InkSparkle.splashFactory,
              tabs: [
                const Tab(
                    icon: Icon(
                  Icons.history,
                  color: Color.fromRGBO(0, 158, 247, 1),
                )),
                Tab(
                    child: Text(
                  "Log_mission_header".tr(),
                  style: const TextStyle(
                      color: Color.fromRGBO(0, 158, 247, 1), fontSize: 12),
                )),
                Tab(
                    child: Text(
                  "Log_excuse_header".tr(),
                  style: const TextStyle(
                      color: Color.fromRGBO(0, 158, 247, 1), fontSize: 13),
                )),
                Tab(
                  child: Text(
                    "Log_vecation_header".tr(),
                    style: const TextStyle(
                        color: Color.fromRGBO(0, 158, 247, 1), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(physics: BouncingScrollPhysics(), children: [
                  Attendance(),
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
