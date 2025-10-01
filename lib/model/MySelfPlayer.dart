import 'package:test_socket/model/CardGame.dart';

import 'Player.dart';

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
    //TODO: da implementare
  }
}