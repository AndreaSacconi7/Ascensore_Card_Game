import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';

class StartingGame implements ExecutableInClient {

  final List<String> connectedPlayers;

  StartingGame(this.connectedPlayers);

  StartingGame.fromJson(Map<String, dynamic> json) :
    connectedPlayers = List<String>.from(json['executable']['connectedPlayers'] as List);

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleStartingGame(this);
  }

}