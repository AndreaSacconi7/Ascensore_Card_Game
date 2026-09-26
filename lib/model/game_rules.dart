import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player.dart';
import 'package:ascensore_client/model/seed.dart';

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

  /// Strength within a seed: ace, then three, then king (10) down to two.
  static int strength(CardGame card) => switch (card.value) { 1 => 12, 3 => 11, _ => card.value };

  /// Index, in play order, of the card that takes the trick: the highest briscola if any was played,
  /// otherwise the highest card of the lead seed. Mirrors the server, which has the final word.
  static int trickWinnerIndex(List<CardGame> trick, Seed? briscola) {
    var winner = 0;
    for (var i = 1; i < trick.length; i++) {
      final challenger = trick[i];
      final current = trick[winner];
      final beats = challenger.seed == current.seed
          ? strength(challenger) > strength(current)
          : briscola != null && challenger.seed == briscola;
      if (beats) winner = i;
    }
    return winner;
  }

  /// The bet the last player may not make, or null if this player is not last to bet.
  static int? forbiddenBet({
    required List<Player> playerOrder,
    required String myNickname,
    required int cardsInHand,
  }) {
    if (playerOrder.isEmpty || playerOrder.last.nickname != myNickname) {
      return null;
    }
    final others = playerOrder.where((p) => p.nickname != myNickname).fold<int>(0, (sum, p) => sum + p.bet);
    final forbidden = cardsInHand - others;
    return forbidden >= 0 && forbidden <= cardsInHand ? forbidden : null;
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
