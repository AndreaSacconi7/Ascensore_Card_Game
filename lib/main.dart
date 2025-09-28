import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'pages/LoginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080/ws'));
  late final ClientManager clientManager;

  MyApp() {
    clientManager = ClientManager(channel); // Inizializza ClientManager
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(clientManager: clientManager),
    );
  }
}
