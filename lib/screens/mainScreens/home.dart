// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Notification.dart';
import '../../constant/Constants.dart';

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
  int? stillThereDuration;
  String userName = "";
  int? type;
  int? lastType;
  var timer1;
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
  StreamSubscription<ReceivedAction>? _actionStreamSubscription;
  static final awesomeActionStream =
      AwesomeNotifications().actionStream.asBroadcastStream(
    onCancel: (controller) {
      // controller.resume();

      print(controller.isPaused);
    },
    onListen: (controller) async {
      print('Stream resumed');
      if (controller.isPaused) {
        controller.resume();
      }
    },
  );

  Future<void> showDialogforStillthere() {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text('still_there_btn'.tr()),
            content: Text("still_there_description2".tr()),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await clockApi(stillThereTaken: false);
                  },
                  child: Text(
                    "Dismiss".tr(),
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await getCurentAddress();
                    if (Platform.isAndroid) {
                      final dynamic checkingImage = await _openCamera();
                      if (checkingImage == null) {
                        prefs.setBool("StillThereFlag", false);
                      } else {
                        print('Still there Image is :$checkingImage');
                      }
                    }
                    setState(() {
                      type = 5;
                      checkInID = "";
                      lastType = 1;
                      prefs.setInt("TypeID", lastType!);
                      tdata = DateTime.now();
                      timeString =
                          ("Still there at ${DateFormat("hh:mm a").format(DateTime.now())}");
                      isVisible = true;
                    });
                    await clockApi(stillThereTaken: true);
                  },
                  child: Text("still_there_btn".tr()))
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    print(isStillThereWorking);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Allow Natifications"),
            content: Text("Our app would like to send you natifications"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Don't Allow",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  )),
              TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((value) => Navigator.pop(context));
                  },
                  child: Text(
                    "Allow",
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        );
      }
    });

    // listen();

    getSharedPrefs().whenComplete(() {
      if (lastType == 1) {
        DateTime endTime = DateTime.now();
        startSession = DateTime.parse(startTime);
        Duration difference = endTime.difference(startSession!);
        int shours = difference.inHours % 24;
        int sminutes = difference.inMinutes % 60;
        int sseconds = difference.inSeconds % 60;
        // print("$shours hour(s) $sminutes minute(s) $sseconds second(s).");
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
  void dispose() async {
    if (lastType == 1) {
      timer.cancel();
    }
    // c().actionSink.close();
    super.dispose();
  }

  void reset() {
    if (type == 2) {
      //Cancels the timer
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

// function to make the clock work live
  void start() {
    started = true;
    //Creates a new repeating timer
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
      stillThereDuration = (prefs.getInt("StillThereDuration") ?? 0);
    });
  }

  _openCamera() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70);
    if (image == null) {
      return;
    }
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dir = directory.path;

    final imageTemp = File(image.path);
    final File newImage = await imageTemp.copy('$dir/image1.png');
    // print(image.path);
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
    return newImage;
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
    // print("the current address is $curentAddress");
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
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image(image: AssetImage('assets/images/clock.png')),
            ),
            Text(
              "$digitalHours:$digitalMinutes:$digitalSeconds",
              style: const TextStyle(
                  color: Color(0xFF1C325E),
                  fontSize: 48,
                  fontWeight: FontWeight.w500),
            ),
            (type == 1 || lastType == 1 || type == 5)
                ? _checkOutbutton()
                : _checkINbutton(),
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

  clockApi({stillThereTaken = false}) async {
    var headers = {
      'accept': '*/*',
      'Authorization': 'bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$URL_Domin/Clocking'));
    if (type == 5) {
      request.body = json.encode({
        "userID": userID,
        "type": type,
        "lat": curentLat,
        "lng": curentLong,
        "status": stillThereTaken,
        "checkInID": checkInID,
        "location": curentAddress,
        "ip": ipAdd,
        "device": "android",
        "os": "andoird 12",
        "image": encodedImage
      });
    } else {
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
    }

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
      // print(response.reasonPhrase);
    }
  }

  stillThereFunction(stillThereDuration) {
    if (stillThereDuration! > 0) {
      createNormalNotification(stillThereDuration);
      // put the stillThereDuration in the minures parmeter
      showDialogforStillthere();
    }
  }

  void onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _checkINbutton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
        onPressed: () async {
          // if the plat form is android
          if (Platform.isAndroid) {
            // get the current location
            await getCurentAddress();
            // open the camera and get photo
            final dynamic checkingImage = await _openCamera();
            // check if user take an image or not
            if (checkingImage == null) {
              createToste("take_image_order");
            } else {
              print('checkingImage is :$checkingImage');
              setState(() {
                type = 1;
                lastType = 1;
                checkInID = "";
                tdata = DateTime.now();
                timeString =
                    ("Checked in at ${DateFormat("hh:mm a").format(DateTime.now())}");
                isVisible = true;
              });
              // the function that display pop up the still there natification and buton to do the action
              if (type == 1 || type == 5 || type == 4) {
                timer1 = Timer.periodic(
                    Duration(minutes: stillThereDuration ?? 0), (Timer t) {
                  if (stillThereDuration != 0) {
                    stillThereFunction(stillThereDuration);
                  }
                });
              } else {
                timer1.cancel();
              }

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("startTime", tdata.toString());
              prefs.setString("clockString", timeString);
              prefs.setInt("TypeID", type!);

              start();

              await clockApi();
            }
          } else {
            await getCurentAddress();
            setState(() {
              type = 1;
              lastType = 1;
              checkInID = "";
              tdata = DateTime.now();
              timeString =
                  ("Checked in at ${DateFormat("hh:mm a").format(DateTime.now())}");
              isVisible = true;
            });

            if (type == 1 || type == 5 || type == 4) {
              Timer.periodic(Duration(minutes: 1), (Timer t) {
                if (stillThereDuration != 0) {
                  stillThereFunction(stillThereDuration);
                }
              });
            }
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("startTime", tdata.toString());
            prefs.setString("clockString", timeString);
            prefs.setInt("TypeID", type!);
            start();

            await clockApi();
          }
        },
        // ignore: sort_child_properties_last
        child: Text('check_in_btn'.tr(),
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
          timer.cancel();
          if (Platform.isAndroid) {
            if (breakId == 4 || breakId == 0) {
              await getCurentAddress();
              if (Platform.isAndroid) {
                final dynamic checkingImage = await _openCamera();
                if (checkingImage == null) {
                  createToste("take_image_order");
                } else {
                  if (mounted) {
                    setState(() {
                      type = 2;
                      checkedIn = false;
                      lastType = 2;
                      timeString =
                          ("Checked out at ${DateFormat("hh:mm a").format(DateTime.now())}");
                    });
                  }
                }

                reset();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("clockString", timeString);
                prefs.setInt("TypeID", type!);
                await clockApi();
              }
            } else {
              return;
            }
          } else {
            if (breakId == 4 || breakId == 0) {
              await getCurentAddress();
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
              prefs.setInt("TypeID", type!);
              await clockApi();
            }
          }
        },
        // ignore: sort_child_properties_last
        child: Text('check_out_btn'.tr(),
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w400)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1C325E),
          fixedSize: Size(240, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
      ),
    );
  }
}
