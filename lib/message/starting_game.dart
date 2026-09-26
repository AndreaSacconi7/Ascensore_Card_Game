import '../client_manager.dart';
import 'executable_in_client.dart';

class StartingGame implements ExecutableInClient {
  /// Nicknames in betting order.
  final List<String> connectedPlayers;

  StartingGame.fromJson(Map<String, dynamic> json)
      : connectedPlayers = List<String>.from(json['connectedPlayers'] as List);

  @override
  void execute({required ClientManager clientManager}) => clientManager.handleStartingGame(this);
}
