import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/executable_in_client.dart';

class PlayerExitGame implements ExecutableInClient {

  final String nickname;

  PlayerExitGame(this.nickname);

  PlayerExitGame.fromJson(Map<String, dynamic> json) :
        nickname = json['executable']['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handlePlayerExitGame(this);
  }
}