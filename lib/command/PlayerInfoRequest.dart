import 'package:test_socket/command/ExecutableInServer.dart';

class PlayerInfoRequest implements ExecutableInServer{

  final String token;

  PlayerInfoRequest({
    required this.token,
  });

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
      "token": token
    };
    return executableArgs;
  }

}