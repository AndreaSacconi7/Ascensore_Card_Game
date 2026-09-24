import 'package:ascensore_client/command/executable_in_server.dart';

class JoinGameRequest implements ExecutableInServer {

  final String nickname;

  JoinGameRequest({
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