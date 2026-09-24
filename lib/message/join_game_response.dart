import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/executable_in_client.dart';

class JoinGameResponse implements ExecutableInClient {

  final String nickname;
  final bool isJoined;

  JoinGameResponse(
      this.nickname,
      this.isJoined,
      );

  JoinGameResponse.fromJson(Map<String, dynamic> json) :
        nickname = json['executable']['nickname'] as String,
        isJoined = json['executable']['isJoined'] as bool;

  @override
  void execute({required ClientManager clientManager}) {
      clientManager.handleJoinGameResponse(this);
  }

}