import 'package:ascensore_client/model/card_game.dart';

import 'player.dart';

class MySelfPlayer extends Player{

  List<CardGame> handCards = [];

  MySelfPlayer(super.nickname);

  void setHandCards(List<CardGame> newHandCards) {
    handCards = newHandCards;
  }

  List<CardGame> getHandCards() {
    return handCards;
  }

  void removeCardFromHand(CardGame card) {
    handCards.removeWhere((c) => c.seed == card.seed && c.value == card.value);
  }
}