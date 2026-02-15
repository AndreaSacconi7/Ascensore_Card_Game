import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/ExecutableInClient.dart';

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