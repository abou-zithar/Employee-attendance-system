import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        // ignore: prefer_const_constructors
        decoration: BoxDecoration(
            // ignore: prefer_const_constructors
            image: DecorationImage(
                image: const AssetImage('assets/images/background.png'),
                fit: BoxFit.fill)),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 170),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFF009EF7),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "mission_label".tr(),
                            style: const TextStyle(
                                fontSize: 26, color: Colors.white),
                          )),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/missions');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFF007BC1),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "vacation_label".tr(),
                            style: const TextStyle(
                                fontSize: 26, color: Colors.white),
                          )),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/vac');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFF005484),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "excuse_label".tr(),
                            style: const TextStyle(
                                fontSize: 26, color: Colors.white),
                          )),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/excuse');
                    },
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
