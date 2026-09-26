import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/game_rules.dart';
import 'package:ascensore_client/model/player.dart';
import 'package:ascensore_client/model/seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameRules.isValidCard', () {
    final hand = [const CardGame(Seed.COINS, 3), const CardGame(Seed.SWORDS, 7)];

    test('any card is valid when leading the trick', () {
      expect(GameRules.isValidCard(leadCard: null, hand: hand, card: hand[1]), isTrue);
    });

    test('following the lead seed is valid', () {
      const lead = CardGame(Seed.COINS, 10);
      expect(GameRules.isValidCard(leadCard: lead, hand: hand, card: hand[0]), isTrue);
    });

    test('must follow the lead seed when holding it', () {
      const lead = CardGame(Seed.COINS, 10);
      expect(GameRules.isValidCard(leadCard: lead, hand: hand, card: hand[1]), isFalse);
    });

    test('any card is valid when the lead seed is not in hand', () {
      const lead = CardGame(Seed.CUPS, 1);
      expect(GameRules.isValidCard(leadCard: lead, hand: hand, card: hand[1]), isTrue);
    });
  });

  group('GameRules.isValidBet', () {
    late List<Player> order;

    setUp(() {
      order = [Player('alice'), Player('bob'), Player('me')];
      order[0].bet = 1;
      order[1].bet = 1;
    });

    test('players other than the last one can bet anything', () {
      expect(
        GameRules.isValidBet(playerOrder: order, myNickname: 'bob', bet: 1, cardsInHand: 3),
        isTrue,
      );
    });

    test('last player cannot make total bets equal cards in hand', () {
      expect(
        GameRules.isValidBet(playerOrder: order, myNickname: 'me', bet: 1, cardsInHand: 3),
        isFalse,
      );
    });

    test('last player can bet when total differs from cards in hand', () {
      expect(
        GameRules.isValidBet(playerOrder: order, myNickname: 'me', bet: 0, cardsInHand: 3),
        isTrue,
      );
    });
  });

  group('CardGame', () {
    test('parses server JSON and resolves its image asset', () {
      final card = CardGame.fromJson({'seed': 'SWORDS', 'value': 4});
      expect(card.seed, Seed.SWORDS);
      expect(card.value, 4);
      expect(card.imagePath, 'assets/cards/SWORDS_4.png');
    });
  });

  group('GameRules.trickWinnerIndex', () {
    test('ace, then three, beat the king of the same seed', () {
      const trick = [CardGame(Seed.CUPS, 10), CardGame(Seed.CUPS, 3), CardGame(Seed.CUPS, 1)];
      expect(GameRules.trickWinnerIndex(trick, Seed.SWORDS), 2);
      expect(GameRules.trickWinnerIndex(trick.sublist(0, 2), Seed.SWORDS), 1);
    });

    test('any briscola beats the lead seed; other seeds never win', () {
      const trick = [CardGame(Seed.CUPS, 1), CardGame(Seed.COINS, 1), CardGame(Seed.SWORDS, 2)];
      expect(GameRules.trickWinnerIndex(trick, Seed.SWORDS), 2);
      expect(GameRules.trickWinnerIndex(trick, null), 0);
    });
  });

  group('GameRules.forbiddenBet', () {
    test('only the last bettor has a forbidden bet', () {
      final order = [Player('alice')..bet = 1, Player('bob')..bet = 0, Player('me')];
      expect(GameRules.forbiddenBet(playerOrder: order, myNickname: 'me', cardsInHand: 3), 2);
      expect(GameRules.forbiddenBet(playerOrder: order, myNickname: 'bob', cardsInHand: 3), isNull);
    });

    test('no forbidden bet when the others already bet more than the tricks', () {
      final order = [Player('alice')..bet = 3, Player('me')];
      expect(GameRules.forbiddenBet(playerOrder: order, myNickname: 'me', cardsInHand: 2), isNull);
    });
  });
}
