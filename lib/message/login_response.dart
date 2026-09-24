
import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/executable_in_client.dart';

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
  void execute({required ClientManager clientManager}) {
      // Login gestito tramite Supabase + PLAYER_INFO_RESPONSE
  }



}