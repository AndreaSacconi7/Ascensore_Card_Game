import 'dart:math';

import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/game_rules.dart';
import 'package:ascensore_client/model/seed.dart';
import 'package:ascensore_client/offline/bot.dart';
import 'package:flutter_test/flutter_test.dart';

List<CardGame> deck(Random random) => [
      for (final seed in Seed.values)
        for (var value = 1; value <= 10; value++) CardGame(seed, value),
    ]..shuffle(random);

void main() {
  final random = Random(7);
  final bot = BotBrain(random);

  test('bets stay within the hand and avoid the forbidden bet', () {
    for (var i = 0; i < 500; i++) {
      final cards = deck(random);
      final hand = cards.sublist(0, 1 + random.nextInt(10));
      final forbidden = random.nextBool() ? random.nextInt(hand.length + 1) : null;
      final bet = bot.chooseBet(
        hand: hand,
        briscola: random.nextBool() ? Seed.values[random.nextInt(4)] : null,
        players: 2 + random.nextInt(3),
        forbidden: forbidden,
      );
      expect(bet, inInclusiveRange(0, hand.length));
      expect(bet, isNot(forbidden));
    }
  });

  test('cards played always follow the lead seed when required', () {
    for (var i = 0; i < 500; i++) {
      final cards = deck(random);
      final hand = cards.sublist(0, 1 + random.nextInt(10));
      final trick = cards.sublist(20, 20 + random.nextInt(4));
      final card = bot.chooseCard(
        hand: hand,
        trick: trick,
        briscola: Seed.values[random.nextInt(4)],
        tricksNeeded: random.nextInt(3) - 1,
      );
      expect(hand, contains(card));
      expect(GameRules.isValidCard(leadCard: trick.isEmpty ? null : trick.first, hand: hand, card: card), isTrue);
    }
  });

  test('when it needs the trick it wins as cheaply as possible', () {
    final card = bot.chooseCard(
      hand: const [CardGame(Seed.CUPS, 1), CardGame(Seed.CUPS, 9), CardGame(Seed.CUPS, 2)],
      trick: const [CardGame(Seed.CUPS, 8)],
      briscola: Seed.SWORDS,
      tricksNeeded: 1,
    );
    expect(card, const CardGame(Seed.CUPS, 9));
  });

  test('when it has its tricks it dumps a strong card that still loses', () {
    final card = bot.chooseCard(
      hand: const [CardGame(Seed.COINS, 1), CardGame(Seed.COINS, 2)],
      trick: const [CardGame(Seed.CUPS, 5), CardGame(Seed.SWORDS, 2)],
      briscola: Seed.SWORDS,
      tricksNeeded: 0,
    );
    expect(card, const CardGame(Seed.COINS, 1), reason: 'the ace of coins cannot win against a briscola');
  });
}
