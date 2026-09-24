import 'package:ascensore_client/message/executable_in_client.dart';
import 'package:ascensore_client/model/player_state.dart';

import '../client_manager.dart';

class PlayerStateUpdate implements ExecutableInClient {

  final PlayerState playerState;

  final String nickname;

  PlayerStateUpdate(this.playerState, this.nickname);

  PlayerStateUpdate.fromJson(Map<String, dynamic> json) :
        playerState = PlayerState.values.firstWhere((e) => e.toString() == 'PlayerState.${json['executable']['playerState']}'),
        nickname = json['executable']['nickname'] as String;

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handlePlayerStateUpdate(this);
  }
}