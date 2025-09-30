import 'package:test_socket/model/Card.dart';

import 'Player.dart';

class MySelfPlayer extends Player{

  List<Card> handCards = [];

  MySelfPlayer(super.nickname);

  void setHandCards(List<Card> newHandCards) {
    handCards = newHandCards;
  }

  List<Card> getHandCards() {
    return handCards;
  }

  void removeCardFromHand(Card card) {
    //TODO: da implementare
  }
}