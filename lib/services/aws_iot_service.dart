// aws_iot_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AwsIotService {
  final String broker = 'a2myxdlmwu3fx-ats.iot.ap-southeast-1.amazonaws.com';
  final int port = 8883;
  final String clientIdentifier = Uuid().v4();
  final String username = 'struv_ilham';
  final String password = 'matdEh-geqdo3-pekzah';

  MqttServerClient? client;
  bool isConnected = false;

  Future<void> connect() async {
    client = MqttServerClient(broker, clientIdentifier);
    client!.port = port;
    client!.secure = true;
    client!.securityContext = SecurityContext.defaultContext;
    client!.logging(on: true);

    final rootCa = await rootBundle.loadString('assets/certs/AmazonRootCA1.pem');
    final deviceCert = await rootBundle.loadString('assets/certs/5ad413cbd19e293fab7e5ab5e057be06bfde0634e414171a821e985915a7164a-certificate.pem.crt');
    final privateKey = await rootBundle.loadString('assets/certs/5ad413cbd19e293fab7e5ab5e057be06bfde0634e414171a821e985915a7164a-private.pem.key');

    client!.securityContext.setTrustedCertificatesBytes(rootCa.codeUnits);
    client!.securityContext.useCertificateChainBytes(deviceCert.codeUnits);
    client!.securityContext.usePrivateKeyBytes(privateKey.codeUnits);

    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMess;

    try {
      print('Connecting...');
      await client!.connect(username, password);
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
    }
  }

  void onConnected() {
    print('Connected');
    isConnected = true;
  }

  void onDisconnected() {
    print('Disconnected');
    isConnected = false;
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void publish(String topic, String message) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      final payload = jsonEncode({'message': message});
      builder.addString(payload);
      print('Publishing message: $payload to topic: $topic');
      client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('Not connected');
    }
  }

  void subscribe(String topic) {
    if (isConnected) {
      client!.subscribe(topic, MqttQos.atMostOnce);
      print('Subscribed to topic: $topic');
    } else {
      print('Not connected');
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => client?.updates;

  Future<void> sendDataToRestApi(String endpoint, String deviceId, String status) async {
    final url = Uri.parse('http://192.168.1.8:8080/$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id-alat': deviceId,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data: ${response.statusCode}');
    }
  }
}
