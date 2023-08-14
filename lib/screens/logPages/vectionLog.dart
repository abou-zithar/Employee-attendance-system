import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class VecationLogScreen extends StatefulWidget {
  const VecationLogScreen({Key? key}) : super(key: key);

  @override
  State<VecationLogScreen> createState() => _VecationLogScreenState();
}

class _VecationLogScreenState extends State<VecationLogScreen> {
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
    String days = "Days_label".tr();
    String from = "From_label".tr();
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: lconsList[iconIndex],
            title: Text('${data["vaction"]}'.tr()),
            subtitle: Text('$from : ${data["from"].toString().split("T")[0]}'),
            trailing: Text("$days : ${data["days"]}"),
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
        http.Request('GET', Uri.parse('$URL_Domin/log/GetVacations/${userID}'));

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        print(data);
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
            //   padding: const EdgeInsets.all(20.0),
            //   child: Text(
            //     "Log_vecation_header".tr(),
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
                    if (data["message"] == "no vacation made") {
                      return Center(
                          child: Text(data["message"],
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40)));
                    } else {
                      return createCard(data[index]);
                    }
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
