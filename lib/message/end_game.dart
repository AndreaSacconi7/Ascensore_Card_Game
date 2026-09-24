import '../client_manager.dart';
import 'executable_in_client.dart';

class EndGame implements ExecutableInClient {

  final Map<String, int> gameResult;

  EndGame.fromJson(Map<String, dynamic> json) :
        gameResult = (json['executable']['gameResult']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          value as int,
        ));

  @override
  void execute({required ClientManager clientManager}) {

    clientManager.handleEndGame(this);
  }
}