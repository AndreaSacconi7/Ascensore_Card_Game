import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/executable_in_client.dart';

import '../model/card_game.dart';

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