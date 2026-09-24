
import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';

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