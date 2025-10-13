import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

class StartingGame implements ExecutableInClient {

  final List<String> connectedPlayers;

  StartingGame(this.connectedPlayers);

  StartingGame.fromJson(Map<String, dynamic> json) :
    connectedPlayers = List<String>.from(json['executable']['connectedPlayers'] as List);

  @override
  void execute({required PageInterface page}) {
    page.handleStartingGame(this);
  }

}