// homePage.dart
import 'package:flutter/material.dart';
import 'package:struviot/db/DatabaseHelper.dart';
import 'package:struviot/screens/detailPage.dart';
import 'package:struviot/screens/qrPage/introQR.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _deviceList;

  @override
  void initState() {
    super.initState();
    _deviceList = DatabaseHelper.instance.queryAllRows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'StruvIoT',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xFF274C77),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 180),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IntroQRPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF274C77),
                ),
                child: const Text(
                  'Tambah alat +',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _deviceList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada data');
                } else {
                  return Column(
                    children: List.generate(snapshot.data!.length, (index) {
                      String deviceId = snapshot.data![index]['name'];
                      return _buildDeviceCard(deviceId, "Off");
                    }),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String deviceId, String status) {
    return Card(
      elevation: 4.0,
      child: ListTile(
        title: Text('StruvIot #$deviceId'),
        subtitle: Text('Status: $status'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(deviceId: deviceId),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDeleteConfirmationDialog(deviceId);
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String deviceId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus ID Alat: $deviceId?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice(deviceId);
              },
            ),
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDevice(String deviceId) async {
    await DatabaseHelper.instance.delete(deviceId);
    setState(() {
      _deviceList = DatabaseHelper.instance.queryAllRows();
    });
  }
}
