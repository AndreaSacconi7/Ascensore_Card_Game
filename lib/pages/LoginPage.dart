import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/model/MySelfPlayer.dart';
import 'package:test_socket/pages/PageInterface.dart';
import 'package:test_socket/widgets/BetWidget.dart';
import 'package:test_socket/widgets/PlayerWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../command/Command.dart';
import '../command/CommandType.dart';
import '../command/LoginRequest.dart';
import '../message/Message.dart';
import 'HomePage.dart';
import '../message/LoginResponse.dart';

class LoginPage extends StatefulWidget {

  ClientManager clientManager;

  LoginPage({required this.clientManager});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements PageInterface{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String nickname = '';
  String pwd = '';

  @override
  void initState() {
    super.initState();
    widget.clientManager.setCurrentPage(this);
  }

  @override
  void handleLoginResponse(LoginResponse response) {
    /*final loginMap = jsonDecode(message) as Map<String, dynamic>;
    //final user = User.fromJson(userMap);
    //final json = jsonDecode(message);
    final response = LoginResponse.fromJson(loginMap);*/

    if(response.nickname == nickname){
      //debug
      print('Response of the server: ${response.isLogged}, ${response.nickname}');

      if (response.isLogged) {
        print('Welcome, ${response.nickname}');

        //creo il player del client
        MySelfPlayer mySelfPlayer = MySelfPlayer(response.nickname);
        widget.clientManager.setMySelfPlayer(mySelfPlayer);

        //print('Connected players: ${response.connectedPlayers}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(clientManager: widget.clientManager),
          ),
        );
      } else {
        print('Login failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login fallito")),
        );
      }
    }
  }

  void _sendLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    nickname = username;
    pwd = password;

    /*final command = {
      "commandType": "LOGIN_COMMAND",
      "executable": {
        "nickname": username,
        "password": password
      }
    };*/
    // Converti l'oggetto Dart in una stringa JSON
    //final jsonCommand = jsonEncode(command);

    LoginRequest loginRequest = LoginRequest(username: username, password: password);

    Command command = Command(
      commandType: CommandType.LOGIN_COMMAND,
      executable: loginRequest,
      nickName: username,
    );
    final jsonCommand = command.toJson();

    widget.clientManager.sendCommand(jsonCommand);

    // Invia la stringa JSON al server
    //widget.channel.sink.add(jsonCommand);


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

  @override
  handleHandUpdate(HandUpdate handUpdate) {

  }

}