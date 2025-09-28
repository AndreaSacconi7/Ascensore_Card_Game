import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';

class LoginResponse implements ExecutableInClient {
  final bool isLogged;
  final String nickname;
  //List<String> connectedPlayers;

  LoginResponse(
    this.isLogged,
    this.nickname,
    //this.connectedPlayers
  );


  LoginResponse.fromJson(Map<String, dynamic> json) :
        //connectedPlayers = json['executable']['connectedPlayers'] as List<String>,
        isLogged = json['executable']['isLogged'] as bool,
        nickname = json['executable']['nickname'] as String;


  @override
  void execute() {
    // TODO: implement execute
  }

  @override
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isLogged': isLogged,
      'nickname': nickname,
      //'connectedPlayers': connectedPlayers,
    };
  }

}