import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class ExcuseLogScreen extends StatefulWidget {
  const ExcuseLogScreen({Key? key}) : super(key: key);

  @override
  State<ExcuseLogScreen> createState() => _ExcuseLogScreenState();
}

class _ExcuseLogScreenState extends State<ExcuseLogScreen> {
  String token = "";
  String userID = "";
  var data;

  void initState() {
    super.initState();
    getSharedPrefs().whenComplete(() {
      getTheVecationLogDetails();
    });
  }

  Widget createCard(data) {
    const lconsList = [
      Icon(
        FontAwesomeIcons.n,
        color: Colors.grey,
      ),
      Icon(
        FontAwesomeIcons.check,
        color: Colors.green,
      ),
      Icon(
        FontAwesomeIcons.xmark,
        color: Colors.red,
      )
    ];
    var iconIndex = 0;
    if (data["status"] == "New") {
      iconIndex = 0;
    } else if (data["status"] == "Approved") {
      iconIndex = 1;
    } else {
      iconIndex = 2;
    }

    String date = "Date_label".tr();
    // String from = "From_label".tr();
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: lconsList[iconIndex],
            title: Text('${data["excuse"]}'.tr()),
            subtitle: Text('$date : ${data["date"].toString().split("T")[0]}'),
            trailing: Text("${data["exMessage"]}"),
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

  getTheVecationLogDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {'accept': '*/*', 'Authorization': "bearer $token"};
    var request =
        http.Request('GET', Uri.parse('$URL_Domin/log/GetExcuses/${userID}'));

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        // print(data);
        // String data_string = json.encode(data["clocks"]);
        // prefs.setString("history_of_use_vecations", data_string);

        // print(data["clocks"][0]["checkDate"].toString().split("T")[0]);
      });

      // print();
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(data);
    if (data == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Text(
            //     "Log_excuse_header".tr(),
            //     style: const TextStyle(
            //         fontSize: 32,
            //         fontWeight: FontWeight.w500,
            //         color: Color(0xFF1C325E)),
            //   ),
            // ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return createCard(data[index]);
                  },
                  itemCount: data.length,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
