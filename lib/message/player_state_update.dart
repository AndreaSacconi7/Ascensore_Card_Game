import '../client_manager.dart';
import '../model/player_state.dart';
import 'executable_in_client.dart';

class PlayerStateUpdate implements ExecutableInClient {
  final PlayerState playerState;
  final String nickname;

  PlayerStateUpdate.fromJson(Map<String, dynamic> json)
      : playerState = PlayerState.values.byName(json['playerState'] as String),
        nickname = json['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) => clientManager.handlePlayerStateUpdate(this);
}
