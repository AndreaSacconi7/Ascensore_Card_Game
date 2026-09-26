import 'dart:math';

import '../model/card_game.dart';
import '../model/game_rules.dart';
import '../model/seed.dart';

/// Decisions of a computer opponent: a simple, readable strategy rather than a perfect one.
///
/// Betting estimates how many tricks the hand is likely to take. Playing tries to make exactly the bet:
/// win cheaply while tricks are still needed, otherwise get rid of strong cards without taking the trick.
class BotBrain {
  BotBrain([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// How many tricks to bet with [hand]; never [forbidden] (the bet the last player may not make).
  int chooseBet({
    required List<CardGame> hand,
    required Seed? briscola,
    required int players,
    required int? forbidden,
  }) {
    final expected = hand.fold<double>(0, (sum, card) => sum + _winChance(card, briscola, players));
    var bet = expected.round().clamp(0, hand.length);
    if (bet == forbidden) {
      // Move towards where the estimate leans, staying within 0..hand size
      final up = bet + 1 <= hand.length;
      final down = bet - 1 >= 0;
      bet = (up && (expected > bet || !down)) ? bet + 1 : bet - 1;
    }
    return bet;
  }

  /// The card to play from [hand], following the lead seed when required.
  CardGame chooseCard({
    required List<CardGame> hand,
    required List<CardGame> trick,
    required Seed? briscola,
    required int tricksNeeded,
  }) {
    final lead = trick.isEmpty ? null : trick.first;
    final valid = hand.where((c) => GameRules.isValidCard(leadCard: lead, hand: hand, card: c)).toList();
    final wantsTrick = tricksNeeded > 0;
    // In the peak set the first card of the trick becomes the briscola
    final trump = briscola ?? lead?.seed;

    if (trick.isEmpty) {
      final byPower = List.of(valid)..sort((a, b) => _power(a, trump).compareTo(_power(b, trump)));
      return wantsTrick ? byPower.last : byPower.first;
    }

    final winning = valid.where((c) => _wouldWin(c, trick, trump)).toList()
      ..sort((a, b) => _power(a, trump).compareTo(_power(b, trump)));
    final losing = valid.where((c) => !_wouldWin(c, trick, trump)).toList()
      ..sort((a, b) => _power(a, trump).compareTo(_power(b, trump)));

    if (wantsTrick) {
      // Win as cheaply as possible, or throw away the weakest card
      return winning.isNotEmpty ? winning.first : losing.first;
    }
    // Get rid of the strongest card that still loses, or win with the weakest if there is no choice
    return losing.isNotEmpty ? losing.last : winning.first;
  }

  bool _wouldWin(CardGame card, List<CardGame> trick, Seed? trump) {
    final all = [...trick, card];
    return GameRules.trickWinnerIndex(all, trump) == all.length - 1;
  }

  // Rough overall strength: any briscola beats any other seed
  int _power(CardGame card, Seed? trump) => GameRules.strength(card) + (card.seed == trump ? 20 : 0);

  // Chance that this card takes a trick, from its rank and whether it is briscola
  double _winChance(CardGame card, Seed? briscola, int players) {
    final strength = GameRules.strength(card); // 2..12, ace = 12
    final crowd = 2 / players; // more opponents, fewer tricks for each card
    if (briscola == null) {
      // Peak set: whoever leads chooses the briscola
      return strength >= 11 ? 0.55 * crowd + _jitter() : 0.05;
    }
    if (card.seed == briscola) {
      return (0.35 + 0.05 * strength).clamp(0.0, 0.95) * (0.85 + 0.15 * crowd);
    }
    if (strength == 12) return 0.7 * crowd + _jitter();
    if (strength == 11) return 0.45 * crowd;
    if (strength >= 9) return 0.15 * crowd;
    return 0.02;
  }

  // A little variety, so bots do not all bet the same with similar hands
  double _jitter() => (_random.nextDouble() - 0.5) * 0.1;
}
