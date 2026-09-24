import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player.dart';

/// Regole di gioco verificate lato client prima di inviare un comando al server.
class GameRules {
  GameRules._();

  /// Chi non apre il giro deve rispondere al seme della prima carta giocata,
  /// se ne ha almeno una in mano.
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

  /// L'ultimo giocatore a scommettere non può rendere la somma delle
  /// scommesse uguale al numero di carte in mano.
  static bool isValidBet({
    required List<Player> playerOrder,
    required String myNickname,
    required int bet,
    required int cardsInHand,
  }) {
    if (playerOrder.last.nickname != myNickname) {
      return true;
    }
    final totalBets = playerOrder.fold<int>(bet, (sum, p) => sum + p.getBet());
    return totalBets != cardsInHand;
  }
}
