import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/nav");
          },
          icon: const Icon(FontAwesomeIcons.angleLeft),
        ),
        title: Image.asset(
          'assets/images/logo_white.png',
          fit: BoxFit.contain,
          height: 28,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 158, 247, 1),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Image.asset("assets/images/logo.png"),
            const SizedBox(height: 20.0),
            const Text(
                "Our employee attendance system is a user-friendly mobile application designed to streamline the process of tracking employee attendance. The application allows employees to check in and out with ease, using their smartphones or tablets. This eliminates the need for manual sign-in sheets or clunky time clocks, making the attendance tracking process more efficient and accurate. The application also allows managers to view attendance records in real-time, and generate reports to track attendance trends over time. Additionally, the application can be integrated with payroll systems, making it a one-stop-shop for managing employee attendance and compensation. With our application, you can have peace of mind knowing that your attendance tracking is accurate and efficient."),
            const SizedBox(height: 50.0),
            const Text("Contact Us",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Email: contact@ourcompany.com"),
            const Text("Phone: 0100-555-5555"),
            const Text("Address: 123 Main St, Anytown EG 12345"),
          ],
        ),
      ),
    );
  }
}
