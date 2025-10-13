import 'package:test_socket/command/ExecutableInServer.dart';

class SetBet implements ExecutableInServer {

  final int bet;
  final String nickname;

  SetBet({
    required this.bet,
    required this.nickname,
  });

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
      "bet": bet,
      "nickname": nickname,
    };
    return executableArgs;
  }


}