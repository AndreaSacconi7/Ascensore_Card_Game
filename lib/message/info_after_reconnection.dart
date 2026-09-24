import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/executable_in_client.dart';

class InfoAfterReconnection implements ExecutableInClient{

  final Map<String, int> scores;
  final Map<String, int> bets;
  final Map<String, int> roundsWon;

  InfoAfterReconnection.fromJson(Map<String, dynamic> json) :
        scores = (json['executable']['scores']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          value as int,
        )),
        bets = (json['executable']['bets']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          value as int,
        )),
        roundsWon = (json['executable']['roundsWon']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          value as int,
        ));

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleInfoAfterReconnection(this);
  }


}