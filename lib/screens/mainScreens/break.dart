// ignore_for_file: override_on_non_overriding_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({Key? key}) : super(key: key);

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  @override
  File? imageFile;
  String? encodedImage;
  String? curentAddress;
  var curentPos;
  String? curentLat;
  String? curentLong;
  String? token;
  String? userID;
  String? checkInID;
  String userName = "";
  int? type;
  int? lastType;
  int? breakId;
  String? ipAdd;
  int myIndex = 0;
  DateTime? tdataB;
  DateTime? startSessionB;
  String startTimeB = '';

  int seconds = 0, minutes = 0, hours = 0;
  int? lastBreak;
  String digitalSeconds = "00", digitalMinutes = "00", digitalHours = "00";
  late Timer timer;
  bool started = false;
  bool checkedIn = false;

  @override
  void initState() {
    super.initState();
    getSharedPrefs().whenComplete(() {
      if (breakId == 3) {
        DateTime endTime = DateTime.now();
        startSessionB = DateTime.parse(startTimeB);
        Duration difference = endTime.difference(startSessionB!);
        int shours = difference.inHours % 24;
        int sminutes = difference.inMinutes % 60;
        int sseconds = difference.inSeconds % 60;
        // print("$shours hour(s) $sminutes minute(s) $sseconds second(s).");
        digitalSeconds = (sseconds >= 10) ? "$sseconds" : "0$sseconds";
        digitalMinutes = (sminutes >= 10) ? "$sminutes" : "0$sminutes";
        digitalHours = (shours >= 10) ? "$shours" : "0$shours";

        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          sseconds = sseconds + 1;
          sminutes = sminutes;
          shours = shours;

          if (sseconds > 59) {
            sminutes++;
            sseconds = 0;
            if (sminutes > 59) {
              shours++;
              sminutes = 0;
            }
          }
          if (mounted) {
            setState(() {
              seconds = sseconds;
              minutes = sminutes;
              hours = shours;

              digitalSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
              digitalMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
              digitalHours = (hours >= 10) ? "$hours" : "0$hours";
            });
          }
        });
      }
    });

    printIps();
  }

  @override
  void dispose() {
    if (breakId == 3) {
      timer.cancel();
    }
    super.dispose();
  }

  reset() {
    timer.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;

      digitalHours = "00";
      digitalMinutes = "00";
      digitalSeconds = "00";
      started = false;
    });
  }

  void start() {
    started = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;
      if (localSeconds > 59) {
        localMinutes++;
        localSeconds = 0;
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        }
      }
      if (mounted) {
        setState(() {
          seconds = localSeconds;
          minutes = localMinutes;
          hours = localHours;
          digitalSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
          digitalMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
          digitalHours = (hours >= 10) ? "$hours" : "0$hours";
        });
      }
    });
  }

  _openCamera() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        // maxHeight: 300,
        // maxWidth: 200,
        imageQuality: 70);
    if (image == null) {
      return;
    }
    final imageTemp = File(image.path);
    final bytes = File(image.path).readAsBytesSync();
    String base64Image = base64Encode(bytes);

    setState(() {
      imageFile = imageTemp;
      encodedImage = base64Image;
    });

    return imageFile;
  }

  getCurentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position pos) async {
      if (mounted) {
        setState(() {
          curentPos = pos;
          curentLat = pos.latitude.toString();
          curentLong = pos.longitude.toString();
        });
      }
    });
  }

  getCurentAddress() async {
    await getCurentLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(curentPos.latitude, curentPos.longitude);
    Placemark place = placemarks[0];
    if (mounted) {
      setState(() {
        curentAddress =
            "${place.street!}, ${place.subAdministrativeArea!}, ${place.administrativeArea!}, ${place.country!}";
      });
    }
  }

  createToste(massage) {
    return Fluttertoast.showToast(
        msg: "$massage".tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // ignore: prefer_const_constructors
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 150),
              child: const Image(image: AssetImage('assets/images/break.png')),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "$digitalHours:$digitalMinutes:$digitalSeconds",
                style: const TextStyle(
                    color: Color(0xFF1C325E),
                    fontSize: 48,
                    fontWeight: FontWeight.w500),
              ),
            ),

            (type == 3 || breakId == 3) ? _breakOut() : _breakIN(),

            const SizedBox(
              height: 40,
            ),
          ]),
        ),
      ),
    );
  }

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = (prefs.getString("token") ?? "No data received");
      userID = (prefs.getString("userID") ?? "No data received");
      breakId = (prefs.getInt("breakID") ?? 0);
      userName = (prefs.getString("userName") ?? "No data received");
      startTimeB = (prefs.getString("startTimeB") ?? "");
      lastType = (prefs.getInt("TypeID") ?? 0);
      checkInID = (prefs.getString("checkInID") ?? "");
    });
  }

  Future printIps() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        ipAdd = addr.address;
      }
    }
  }

  clockApi() async {
    var headers = {
      'accept': '*/*',
      'Authorization': 'bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$URL_Domin/Clocking'));
    request.body = json.encode({
      "userID": userID,
      "type": type,
      "lat": curentLat,
      "lng": curentLong,
      "checkInID": checkInID,
      "location": curentAddress,
      "ip": ipAdd,
      "device": "android",
      "os": "andoird 12",
      "image": encodedImage
    });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decodedMap = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("breakID", type!);
    } else {
      print(response.reasonPhrase);
    }
  }

  Widget _breakIN() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          if (Platform.isAndroid) {
            if (lastType == 1) {
              await getCurentAddress();
              final dynamic checkingImage = await _openCamera();
              if (checkingImage == null) {
                createToste("take_image_order");
                // showDialog(
                //     context: context,
                //     builder: (context) {
                //       return AlertDialog(
                //         title: Text('take_image_order'.tr()),
                //         actions: <Widget>[
                //           TextButton(
                //               onPressed: () {
                //                 Navigator.pop(context);
                //                 // Navigator.pushReplacementNamed(context, '/nav');
                //               },
                //               child: Text('Okay_label'.tr()))
                //         ],
                //       );
                //     });
              } else {
                setState(() {
                  type = 3;
                  tdataB = DateTime.now();
                });

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("startTimeB", tdataB.toString());
                start();

                await clockApi();
              }
            } else {
              return;
            }
          } else {
            if (lastType == 1) {
              await getCurentAddress();
              setState(() {
                type = 3;
                tdataB = DateTime.now();
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("startTimeB", tdataB.toString());
              start();

              await clockApi();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
        child: Text("break_in_btn".tr(),
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _breakOut() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          if (Platform.isAndroid) {
            await getCurentAddress();
            final dynamic checkingImage = await _openCamera();
            if (checkingImage == null) {
              createToste("take_image_order");
              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return AlertDialog(
              //         title: Text('take_image_order'.tr()),
              //         actions: <Widget>[
              //           TextButton(
              //               onPressed: () {
              //                 Navigator.pop(context);
              //                 // Navigator.pushReplacementNamed(context, '/nav');
              //               },
              //               child: Text('Okay_label'.tr()))
              //         ],
              //       );
              //     });
            } else {
              setState(() {
                type = 4;
                checkedIn = false;
                breakId = 4;
              });
              reset();

              await clockApi();
            }
          } else {
            await getCurentAddress();
            setState(() {
              type = 4;
              checkedIn = false;
              breakId = 4;
            });
            reset();

            await clockApi();
          }
        },
        style: ElevatedButton.styleFrom(
          primary: const Color(0xFF1C325E),
          fixedSize: const Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
        child: Text("break_out_btn".tr(),
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
      ),
    );
  }
}
