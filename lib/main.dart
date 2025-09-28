import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'pages/LoginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080/ws'));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(channel: channel),
    );
  }
}
