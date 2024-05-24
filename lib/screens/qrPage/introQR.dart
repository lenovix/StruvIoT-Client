import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:struviot/screens/qrPage/resultQR.dart';

class IntroQRPage extends StatefulWidget {
  const IntroQRPage({Key? key}) : super(key: key);

  @override
  _IntroQRPageState createState() => _IntroQRPageState();
}

class _IntroQRPageState extends State<IntroQRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambahkan alat ...'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Tambahkan alat Struvite',
            style: TextStyle(
              fontSize: 18.0,
              color: Color(0xFF274C77),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Text(
              'Pindai QR Code yang berada pada alat struvite anda untuk menambah alat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(height: 90.0),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        // Menyimpan data QR ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('qrData', scanData.code!);

        // Tutup kamera
        controller.dispose();

        // Navigasi ke halaman ResultQRPage.dart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultQRPage()),
        );
      }
    });
  }
}
