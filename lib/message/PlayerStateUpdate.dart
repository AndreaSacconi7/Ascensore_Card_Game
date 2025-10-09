import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/model/PlayerState.dart';
import 'package:test_socket/pages/PageInterface.dart';

class PlayerStateUpdate implements ExecutableInClient {

  final PlayerState playerState;

  final String nickname;

  PlayerStateUpdate(this.playerState, this.nickname);

  PlayerStateUpdate.fromJson(Map<String, dynamic> json) :
        playerState = PlayerState.values.firstWhere((e) => e.toString() == 'PlayerState.' + json['executable']['playerState']),
        nickname = json['executable']['nickname'] as String;

  @override
  void execute({required PageInterface page}) {
    page.handlePlayerStateUpdate(this);
  }
}