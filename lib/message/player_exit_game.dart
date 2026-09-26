import '../client_manager.dart';
import 'executable_in_client.dart';

class PlayerExitGame implements ExecutableInClient {
  final String nickname;

  PlayerExitGame.fromJson(Map<String, dynamic> json) : nickname = json['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) => clientManager.handlePlayerExitGame(this);
}
