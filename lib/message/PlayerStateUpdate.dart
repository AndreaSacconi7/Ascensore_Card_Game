import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/model/PlayerState.dart';
import 'package:test_socket/pages/PageInterface.dart';

class PlayerStateUpdate implements ExecutableInClient {

  final PlayerState playerState;

  PlayerStateUpdate(this.playerState);

  PlayerStateUpdate.fromJson(Map<String, dynamic> json) :
        playerState = json['executable']['playerState'] as PlayerState;

  @override
  void execute({required PageInterface page}) {
    page.handlePlayerStateUpdate(this);
  }
}