import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/ExecutableInClient.dart';

import '../model/CardGame.dart';
import '../pages/PageInterface.dart';

class PlayedCardUpdate implements ExecutableInClient {

  final String nickname;
  final CardGame playedCard;

  PlayedCardUpdate(this.nickname, this.playedCard);


  factory PlayedCardUpdate.fromJson(Map<String, dynamic> json){

    final playedCard = CardGame.fromJson(json['executable']['playedCard']);
    final nickname = json['executable']['nickname'] as String;

    return PlayedCardUpdate(nickname, playedCard);
  }

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handlePlayedCard(this);
  }

}