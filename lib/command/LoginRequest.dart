import 'package:test_socket/command/ExecutableInServer.dart';

class LoginRequest implements ExecutableInServer{

  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
        "nickname": username,
        "password": password,
    };
    return executableArgs;
  }

}