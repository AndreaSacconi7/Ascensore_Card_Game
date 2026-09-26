import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player.dart';

/// Rules checked on the client before sending a move, for immediate feedback.
/// The server checks them again and has the final word.
class GameRules {
  GameRules._();

  /// A player who holds a card of the lead seed must follow it.
  static bool isValidCard({
    required CardGame? leadCard,
    required List<CardGame> hand,
    required CardGame card,
  }) {
    if (leadCard == null || card.seed == leadCard.seed) {
      return true;
    }
    return !hand.any((c) => c.seed == leadCard.seed);
  }

  /// The last player to bet cannot make the bets add up to the number of tricks.
  static bool isValidBet({
    required List<Player> playerOrder,
    required String myNickname,
    required int bet,
    required int cardsInHand,
  }) {
    if (bet < 0 || bet > cardsInHand) {
      return false;
    }
    if (playerOrder.isEmpty || playerOrder.last.nickname != myNickname) {
      return true;
    }
    final totalBets = playerOrder.fold<int>(bet, (sum, p) => sum + p.bet);
    return totalBets != cardsInHand;
  }
}
