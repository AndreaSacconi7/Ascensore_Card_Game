import '../ClientManager.dart';
import 'ExecutableInClient.dart';

class EndGame implements ExecutableInClient {

  final Map<String, int> gameResult;

  EndGame.fromJson(Map<String, dynamic> json) :
        gameResult = (json['executable']['gameResult']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key as String,
          value as int,
        ));

  @override
  void execute({required ClientManager clientManager}) {

    clientManager.handleEndGame(this);
  }
}