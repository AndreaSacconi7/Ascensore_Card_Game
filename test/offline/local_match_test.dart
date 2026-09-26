import 'package:ascensore_client/app_screen_state.dart';
import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/model/game_rules.dart';
import 'package:ascensore_client/model/player_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// Plays whole offline matches through the client, with the human's moves chosen by the test.
void main() {
  late FakeConnector connector;
  late ClientManager manager;

  void run(void Function(FakeAsync async) body) {
    fakeAsync((async) {
      connector = FakeConnector();
      manager = ClientManager(auth: FakeAuthService(), connector: connector.call);
      body(async);
    });
  }

  // Makes the human's move whenever it is their turn, until the match is over
  void playToTheEnd(FakeAsync async) {
    for (var step = 0; step < 20000 && manager.currentScreen != AppScreenState.gameOver; step++) {
      async.elapse(const Duration(milliseconds: 500));
      final game = manager.game;
      final me = manager.mySelfPlayer;
      if (game == null || me == null) continue;
      if (me.playerState == PlayerState.BET) {
        final forbidden =
            GameRules.forbiddenBet(playerOrder: game.playerOrder, myNickname: me.nickname, cardsInHand: game.set);
        manager.setBet(forbidden == 0 ? 1 : 0);
      } else if (me.playerState == PlayerState.PUT) {
        final leader = game.playerOrder.first;
        final lead = leader == me ? null : leader.playedCard;
        manager.putCard(
            me.handCards.firstWhere((c) => GameRules.isValidCard(leadCard: lead, hand: me.handCards, card: c)));
      }
      // Wait for the move to be applied before deciding again
      async.elapse(const Duration(milliseconds: 100));
    }
  }

  for (final bots in [1, 2, 3]) {
    test(
        'a guest plays a whole offline match against $bots bot(s)',
        () => run((async) {
              manager.playOffline(bots: bots);
              async.flushMicrotasks();

              expect(manager.game!.players, hasLength(bots + 1));
              expect(manager.game!.players.where((p) => p.isBot), hasLength(bots));
              expect(manager.game!.totalSets, 19);

              playToTheEnd(async);

              expect(manager.currentScreen, AppScreenState.gameOver);
              expect(manager.game!.setNumber, 19, reason: 'the last set is the 19th');
              expect(connector.connections, isEmpty, reason: 'offline: no server involved');
            }));
  }

  test(
      'leaving an offline match stops the bots and returns a guest to the login page',
      () => run((async) {
            manager.playOffline(bots: 2);
            async.elapse(const Duration(seconds: 5));

            manager.leaveGame();
            async.elapse(const Duration(seconds: 30));

            expect(manager.isOffline, isFalse);
            expect(manager.game, isNull);
            expect(manager.currentScreen, AppScreenState.login);
          }));

  test(
      'play again starts a new offline match with the same bots',
      () => run((async) {
            manager.playOffline(bots: 3);
            playToTheEnd(async);

            manager.playAgain();
            async.flushMicrotasks();

            expect(manager.currentScreen, AppScreenState.inGame);
            expect(manager.game!.players.where((p) => p.isBot), hasLength(3));
            expect(manager.game!.setNumber, 1);
          }));

  test('messages from the server are ignored during an offline match', () {
    fakeAsync((async) {
      final connector = FakeConnector();
      final manager = ClientManager(auth: FakeAuthService(token: 'token'), connector: connector.call);
      manager.checkLoginStatus();
      async.flushMicrotasks();
      connector.last.receive('PLAYER_INFO_RESPONSE', {'nickname': 'alice', 'isLogged': true, 'inMatch': false});
      async.flushMicrotasks();

      manager.playOffline(bots: 1);
      async.flushMicrotasks();
      final game = manager.game;
      expect(game, isNotNull);

      // A late server message (after a reconnection, for example) must not replace the offline match
      connector.last.receive('PLAYER_INFO_RESPONSE', {'nickname': 'alice', 'isLogged': true, 'inMatch': false});
      async.flushMicrotasks();

      expect(manager.game, same(game));
      expect(manager.currentScreen, AppScreenState.inGame);
      expect(connector.last.sentTypes, isNot(contains('SET_BET')), reason: 'moves never reach the server');
    });
  });
}
