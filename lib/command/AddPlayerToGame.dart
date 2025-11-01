import 'package:test_socket/command/ExecutableInServer.dart';

class AddPlayerToGame implements ExecutableInServer {

  final String nickname;

  AddPlayerToGame({
    required this.nickname,
  });

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
      "nickname": nickname,
    };
    return executableArgs;
  }
}