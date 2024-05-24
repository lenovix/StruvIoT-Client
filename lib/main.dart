import 'package:flutter/material.dart';
import 'package:struviot/db/DatabaseHelper.dart';
import 'package:struviot/screens/homePage.dart';
import 'package:struviot/screens/qrPage/introQR.dart';
import 'package:struviot/screens/qrPage/resultQR.dart';
import 'package:struviot/screens/splashScreen.dart';
import 'package:struviot/screens/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> devices = await databaseHelper.queryAllRows();

  runApp(MyApp(hasDevices: devices.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool hasDevices;

  const MyApp({required this.hasDevices, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StruvIoT',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      initialRoute: hasDevices ? '/splashScreen' : '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/splashScreen': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/introQR': (context) => const IntroQRPage(),
        '/resultQR': (context) => const ResultQRPage(),
      },
    );
  }
}
