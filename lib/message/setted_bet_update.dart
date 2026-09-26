import '../client_manager.dart';
import 'executable_in_client.dart';

class SettedBetUpdate implements ExecutableInClient {
  final int bet;
  final String nickname;

  SettedBetUpdate.fromJson(Map<String, dynamic> json)
      : bet = json['bet'] as int,
        nickname = json['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) => clientManager.handleSettedBet(this);
}
