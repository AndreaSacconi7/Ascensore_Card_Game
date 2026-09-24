import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';

class SettedBetUpdate implements ExecutableInClient {

  final int bet;
  final String nickname;

  SettedBetUpdate.fromJson(Map<String, dynamic> json) :
        bet = json['executable']['bet'] as int,
        nickname = json['executable']['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleSettedBet(this);
  }

}