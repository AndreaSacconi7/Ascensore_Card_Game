import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/ExecutableInClient.dart';

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