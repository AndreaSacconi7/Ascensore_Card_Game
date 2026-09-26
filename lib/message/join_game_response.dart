import '../client_manager.dart';
import 'executable_in_client.dart';

class JoinGameResponse implements ExecutableInClient {
  final String nickname;
  final bool isJoined;

  JoinGameResponse.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] as String,
        isJoined = json['isJoined'] as bool;

  @override
  void execute({required ClientManager clientManager}) => clientManager.handleJoinGameResponse(this);
}
