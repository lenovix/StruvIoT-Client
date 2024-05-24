import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:struviot/db/DatabaseHelper.dart';
import 'package:struviot/screens/homePage.dart';

class ResultQRPage extends StatefulWidget {
  const ResultQRPage({Key? key}) : super(key: key);

  @override
  _ResultQRPageState createState() => _ResultQRPageState();
}

class _ResultQRPageState extends State<ResultQRPage> {
  final TextEditingController _qrCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mendapatkan nilai QR code dari SharedPreferences dan menampilkannya di TextField
    _getQRCodeFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/qr-image.png',
              width: double.infinity,
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                readOnly: true,
                controller: _qrCodeController, // Menggunakan controller
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'QR Code',
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 30.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? qrCode = prefs.getString('qrData');

                // Periksa apakah id alat sudah ada di dalam database
                List<Map<String, dynamic>> rows = await DatabaseHelper.instance.queryAllRows();
                bool isIdExists = rows.any((row) => row['name'] == qrCode);

                if (!isIdExists) {
                  // Simpan ID alat ke dalam database jika belum ada
                  await DatabaseHelper.instance.insert(qrCode!);
                }

                // Navigasi ke halaman selanjutnya (opsional)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF274C77),
              ),
              child: const Text(
                'Selanjutnya',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method untuk mendapatkan QR code dari SharedPreferences
  void _getQRCodeFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? qrCode = prefs.getString('qrData');
    if (qrCode != null) {
      setState(() {
        _qrCodeController.text = qrCode; // Mengatur nilai pada TextField
      });
    }
  }
}
