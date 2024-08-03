// detailPage.dart

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

import '../services/aws_iot_service.dart';

class DetailPage extends StatefulWidget {
  final String deviceId;
  const DetailPage({super.key, required this.deviceId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AwsIotService _awsIotService = AwsIotService();

  String _receivedBerat = '-';
  String _receivedSuhu = '-';
  bool _isConnected = false;
  bool _reaktorStatus = false;
  bool _penyaringStatus = false;
  bool _pengeringStatus = false;

  @override
  void initState() {
    super.initState();
    _awsIotService.connect().then((_) {
      setState(() {
        _isConnected = _awsIotService.isConnected;
      });
      _subscribeToTopics();
      _awsIotService.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        Map<String, dynamic> data = jsonDecode(pt);
        String topic = c[0].topic;

        if (topic.endsWith('/reaktor')) {
          setState(() {
            _reaktorStatus = data['status'] == 'on';
          });
        } else if (topic.endsWith('/penyaring')) {
          setState(() {
            _penyaringStatus = data['status'] == 'on';
            _receivedBerat = data['status'] == 'on' ? data['berat'].toString() : '-';
          });
        } else if (topic.endsWith('/pengering')) {
          setState(() {
            _pengeringStatus = data['status'] == 'on';
            _receivedSuhu = data['status'] == 'on' ? data['suhu'].toString() : '-';
          });
        }
      });
    });
  }

  void _subscribeToTopics() {
    String baseTopic = 'struv/${widget.deviceId}';
    _awsIotService.subscribe('$baseTopic/reaktor');
    _awsIotService.subscribe('$baseTopic/penyaring');
    _awsIotService.subscribe('$baseTopic/pengering');
  }

  void _handleSwitchChange(String endpoint, bool value) {
    setState(() {
      if (endpoint == 'reaktor') {
        _reaktorStatus = value;
      } else if (endpoint == 'penyaring') {
        _penyaringStatus = value;
      } else if (endpoint == 'pengering') {
        _pengeringStatus = value;
      }
    });

    _awsIotService.sendDataToRestApi(endpoint, widget.deviceId, value ? 'on' : 'off');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 70,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF274C77),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Text(
              'StruvIot #${widget.deviceId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          _buildDeviceCard('Reaktor', _reaktorStatus, 'Status', _reaktorStatus ? 'On' : 'Off', 'reaktor'),
          const SizedBox(height: 10.0),
          _buildDeviceCard('Penyaring', _penyaringStatus, 'Berat', _penyaringStatus ? _receivedBerat : '-', 'penyaring'),
          const SizedBox(height: 10.0),
          _buildDeviceCard('Pengering', _pengeringStatus, 'Suhu', _pengeringStatus ? _receivedSuhu : '-', 'pengering'),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(String title, bool status, String infoLabel, String infoValue, String endpoint) {
    return Card(
      elevation: 4.0,
      child: ListTile(
        title: Text(title),
        subtitle: infoLabel.isNotEmpty
            ? Row(
          children: [
            Text('$infoLabel: '),
            Text(infoValue),
          ],
        )
            : null,
        trailing: Switch(
          value: status,
          onChanged: (bool value) {
            _handleSwitchChange(endpoint, value);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _awsIotService.client?.disconnect();
    super.dispose();
  }
}
