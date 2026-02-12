import 'package:test_socket/command/ExecutableInServer.dart';

class PlayerInfoRequest implements ExecutableInServer{

  final String token;
  final String nickname;

  PlayerInfoRequest({
    required this.token,
    required this.nickname,
  });

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
      "token": token,
      "nickname": nickname
    };
    return executableArgs;
  }

}