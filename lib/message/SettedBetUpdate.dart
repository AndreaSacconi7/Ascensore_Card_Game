import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

class SettedBetUpdate implements ExecutableInClient {

  final int bet;
  final String nickname;

  SettedBetUpdate.fromJson(Map<String, dynamic> json) :
        bet = json['executable']['bet'] as int,
        nickname = json['executable']['nickname'] as String;

  @override
  void execute({required PageInterface page}) {
    page.handleSettedBet(this);
  }

}