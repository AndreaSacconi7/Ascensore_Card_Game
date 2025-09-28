import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_socket/components/BetWidget.dart';
import 'package:test_socket/components/PlayerWidget.dart';
import 'package:test_socket/components/TakenWidget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'HomePage.dart';
import '../message/LoginResponse.dart';

class LoginPage extends StatefulWidget {
  final WebSocketChannel channel;

  LoginPage({required this.channel});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final Stream _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.channel.stream.asBroadcastStream();
    _stream.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    final loginMap = jsonDecode(message) as Map<String, dynamic>;
    //final user = User.fromJson(userMap);
    //final json = jsonDecode(message);
    final response = LoginResponse.fromJson(loginMap);

    //debug
    print('Response of the server: ${response.isLogged}, ${response.nickname}');

    if (response.isLogged) {
      print('Welcome, ${response.nickname}');
      //print('Connected players: ${response.connectedPlayers}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(channel: widget.channel),
        ),
      );
    } else {
      print('Login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login fallito")),
      );
    }
    /*
    if (message == 'LOGIN_OK') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(channel: widget.channel),
        ),
      );
    } else if (message == 'LOGIN_FAIL') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login fallito")),
      );
    }*/
  }

  void _sendLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final command = {
      "type": "LOGIN_COMMAND",
      "executable": {
        "nickname": username,
        "password": password
      }
    };
    // Converti l'oggetto Dart in una stringa JSON
    final jsonCommand = jsonEncode(command);

    // Invia la stringa JSON al server
    widget.channel.sink.add(jsonCommand);
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(channel: widget.channel),
      ),
    );*/
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _sendLogin, child: Text('Login')),

          ],
        ),
      ),
    );
  }
}