import 'package:flutter/material.dart';
import 'package:struviot/screens/homePage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'StruvIoT',
          style: TextStyle(
            color: Color(0xFF274C77),
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
