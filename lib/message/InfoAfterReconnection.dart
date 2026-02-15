import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/ExecutableInClient.dart';

class InfoAfterReconnection implements ExecutableInClient{

  final Map<String, int> scores;
  final Map<String, int> bets;
  final Map<String, int> roundsWon;

  InfoAfterReconnection.fromJson(Map<String, dynamic> json) :
        scores = (json['executable']['scores']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key as String,
          value as int,
        )),
        bets = (json['executable']['bets']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key as String,
          value as int,
        )),
        roundsWon = (json['executable']['roundsWon']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key as String,
          value as int,
        ));

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleInfoAfterReconnection(this);
  }


}