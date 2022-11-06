// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // variable named image to be named with the path

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
  Uint8List? bytes;
  Image? image;
  String? storedPath;
  String timeString = '';
  String? clockString;
  bool isVisible = false;

  DateTime? tdata;
  DateTime? startSession;
  String startTime = '';
  int myIndex = 0;

  int seconds = 0, minutes = 0, hours = 0;
  String digitalSeconds = "00", digitalMinutes = "00", digitalHours = "00";
  late Timer timer;
  bool started = false;
  bool checkedIn = false;

  @override
  void initState() {
    super.initState();
    getSharedPrefs().whenComplete(() {
      if (lastType == 1) {
        DateTime endTime = DateTime.now();
        startSession = DateTime.parse(startTime);
        Duration difference = endTime.difference(startSession!);
        int shours = difference.inHours % 24;
        int sminutes = difference.inMinutes % 60;
        int sseconds = difference.inSeconds % 60;
        print("$shours hour(s) $sminutes minute(s) $sseconds second(s).");
        digitalSeconds = (sseconds >= 10) ? "$sseconds" : "0$sseconds";
        digitalMinutes = (sminutes >= 10) ? "$sminutes" : "0$sminutes";
        digitalHours = (shours >= 10) ? "$shours" : "0$shours";

        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          sseconds = sseconds + 1;
          sminutes = sminutes;
          shours = shours;
          //print(sessionMinutes);

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
      if (storedPath != null) {
        imageFile = File(storedPath!);
      }
      if (lastType == 0) {
        isVisible = false;
      } else {
        timeString = clockString!;
        isVisible = true;
      }
      // imageFile = File(image!);
    });

    printIps();
  }

  @override
  void dispose() {
    if (lastType == 1) {
      timer.cancel();
    }
    super.dispose();
  }

  reset() {
    if (type == 2) {
      timer.cancel();
    }

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
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

      // if (localSeconds > 59) {
      //   if (localMinutes > 59) {
      //     localHours++;

      //     localMinutes = 0;
      //   } else {
      //     localMinutes++;
      //     localSeconds = 0;
      //   }
      // }
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

  Future getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = (prefs.getString("token") ?? "No data received");
      userID = (prefs.getString("userID") ?? "No data received");
      lastType = (prefs.getInt("TypeID") ?? 0);
      userName = (prefs.getString("userName") ?? "No data received");
      breakId = (prefs.getInt("breakID") ?? 0);
      clockString = (prefs.getString("clockString") ?? "");
      storedPath = prefs.getString(("storedImage"));
      startTime = (prefs.getString("startTime") ?? "");
      checkInID = (prefs.getString("checkInID") ?? "");
    });
  }

  _openCamera() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxHeight: 300,
        maxWidth: 200,
        imageQuality: 90);
    if (image == null) {
      return;
    }
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dir = directory.path;

    final imageTemp = File(image.path);
    final File newImage = await imageTemp.copy('$dir/image1.png');
    print(image.path);
    final bytes = File(image.path).readAsBytesSync();
    String base64Image = base64Encode(bytes);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("storedImage", newImage.path);

    if (mounted) {
      setState(() {
        imageFile = imageTemp;
        encodedImage = base64Image;
      });
    }
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

  Future getCurentAddress() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover).image
                    : AssetImage('assets/images/anonymous.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                userName,
                style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF1C325E),
                    fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Visibility(
                visible: isVisible,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Image(
                        image: AssetImage('assets/images/location.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          timeString,
                          style: TextStyle(fontSize: 17),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image(image: AssetImage('assets/images/clock.png')),
            ),
            Container(
              child: Text(
                "$digitalHours:$digitalMinutes:$digitalSeconds",
                style: const TextStyle(
                    color: Color(0xFF1C325E),
                    fontSize: 48,
                    fontWeight: FontWeight.w500),
              ),
            ),
            (type == 1 || lastType == 1) ? _checkOutbutton() : _checkINbutton(),
            const SizedBox(
              height: 40,
            ),
          ]),
        ),
      ),
    );
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
    var request = http.Request(
        'POST', Uri.parse('http://13.79.147.127/EAT/API/api/Clocking'));
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
      checkInID = decodedMap["id"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("checkInID", decodedMap["id"]);
      prefs.setInt("TypeID", type!);
    } else {
      print(response.reasonPhrase);
    }
  }

  Widget _checkINbutton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          await getCurentAddress();
          await _openCamera();
          setState(() {
            type = 1;
            checkInID = "";
            tdata = DateTime.now();
            timeString =
                ("Checked in at ${DateFormat("hh:mm a").format(DateTime.now())}");
            isVisible = true;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("startTime", tdata.toString());
          prefs.setString("clockString", timeString);

          start();

          await clockApi();
        },
        // ignore: sort_child_properties_last
        child: Text("Check in",
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
      ),
    );
  }

  Widget _checkOutbutton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          if (breakId == 4 || breakId == 0) {
            await getCurentAddress();
            await _openCamera();
            if (mounted) {
              setState(() {
                type = 2;
                checkedIn = false;
                lastType = 2;
                timeString =
                    ("Checked out at ${DateFormat("hh:mm a").format(DateTime.now())}");
              });
            }
            reset();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("clockString", timeString);
            await clockApi();
          } else {
            return;
          }
        },
        // ignore: sort_child_properties_last
        child: Text("Check out",
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF1C325E),
          fixedSize: Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
      ),
    );
  }
}
