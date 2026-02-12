import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../ClientManager.dart';

class PlayerInfoResponse implements ExecutableInClient {
  final String nickname;
  final bool isLogged;
  //TODO: poi qui si possono aggiungere altre info del player tipo experience, coins, buste possedute....

  PlayerInfoResponse(
      this.nickname,
      this.isLogged
  );

  PlayerInfoResponse.fromJson(Map<String, dynamic> json) :
        nickname = json['executable']['nickname'] as String,
        isLogged = json['executable']['isLogged'] as bool;

  @override
  void execute({required ClientManager clientManager}) {
      clientManager.handlePlayerInfo(this);
  }



}