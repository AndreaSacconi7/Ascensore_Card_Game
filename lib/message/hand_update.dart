import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';
import '../model/card_game.dart';

class HandUpdate implements ExecutableInClient {

  final List<CardGame> handCards;

  HandUpdate(this.handCards);

  HandUpdate.fromJson(Map<String, dynamic> json) :
        handCards = (json['executable']['cards'] as List)
            .map((cardJson) => CardGame.fromJson(cardJson as Map<String, dynamic>))
            .toList();

  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleHandUpdate(this);
  }



}