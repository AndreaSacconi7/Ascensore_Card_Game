import 'package:ascensore_client/model/card_game.dart';

import 'player.dart';

/// The local player: the only one whose hand the client knows.
class MySelfPlayer extends Player {
  /// Replaced, never mutated in place, so selectors comparing lists see every change.
  List<CardGame> handCards = const [];

  MySelfPlayer(super.nickname);

  void removeCardFromHand(CardGame card) {
    handCards = handCards.where((c) => c != card).toList();
  }
}
