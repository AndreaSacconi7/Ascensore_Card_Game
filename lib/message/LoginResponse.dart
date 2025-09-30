import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

class LoginResponse implements ExecutableInClient {
  final bool isLogged;
  final String nickname;
  List<String> connectedPlayers;

  LoginResponse(
    this.isLogged,
    this.nickname,
    this.connectedPlayers
  );


  LoginResponse.fromJson(Map<String, dynamic> json) :
        isLogged = json['executable']['isLogged'] as bool,
        nickname = json['executable']['nickname'] as String,
        connectedPlayers = List<String>.from(json['executable']['connectedPlayers'] as List);


  @override
  void execute({required PageInterface page}) {
      page.handleLoginResponse(this);
  }

  @override
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isLogged': isLogged,
      'nickname': nickname,
      'connectedPlayers': connectedPlayers,
    };
  }

}