import 'dart:convert';

class LoginResponse {
  final bool isLogged;
  final String nickname;
  //final List<String> connectedPlayers;

  LoginResponse(
    this.isLogged,
    this.nickname,
    //this.connectedPlayers
  );


  LoginResponse.fromJson(Map<String, dynamic> json) :
        //connectedPlayers = json['executable']['connectedPlayers'] as List<String>,
        isLogged = json['executable']['isLogged'] as bool,
        nickname = json['executable']['nickname'] as String;

}