import 'package:ascensore_client/app_screen_state.dart';
import 'package:ascensore_client/authentication_state.dart';
import 'package:ascensore_client/client_manager.dart';
import 'package:ascensore_client/message/player_info_response.dart';
import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player_state.dart';
import 'package:ascensore_client/model/seed.dart';
import 'package:ascensore_client/model/set_result_animation_state.dart';
import 'package:ascensore_client/network/server_link.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

const displayTime = Duration(seconds: 3);

Map<String, dynamic> card(String seed, int value) => {'seed': seed, 'value': value};

void main() {
  late FakeAuthService auth;
  late FakeConnector connector;
  late ClientManager manager;

  // Everything runs in fake time so result pauses and reconnection backoff are deterministic
  void run(void Function(FakeAsync async) body) {
    fakeAsync((async) {
      auth = FakeAuthService(token: 'token');
      connector = FakeConnector();
      manager = ClientManager(
        auth: auth,
        connector: connector.call,
        resultDisplayTime: displayTime,
        reconnectBackoff: const [Duration(seconds: 1)],
      );
      body(async);
    });
  }

  void server(FakeAsync async, String type, [Map<String, dynamic> executable = const {}]) {
    connector.last.receive(type, executable);
    async.flushMicrotasks();
  }

  void loggedIn(FakeAsync async, String nickname, {bool inMatch = false}) {
    server(async, 'PLAYER_INFO_RESPONSE',
        {'nickname': nickname, 'isLogged': true, 'needsNickname': false, 'inMatch': inMatch});
  }

  // Alice (this client) and Bob in a started match, Alice betting first
  void startMatch(FakeAsync async) {
    manager.checkLoginStatus();
    async.flushMicrotasks();
    loggedIn(async, 'alice');
    manager.joinGame();
    server(async, 'STARTING_GAME', {'connectedPlayers': ['alice', 'bob']});
    server(async, 'HAND_UPDATE', {'cards': [card('CUPS', 1), card('SWORDS', 5)]});
    server(async, 'BRISCOLA_UPDATE', {'briscolaCard': card('COINS', 7)});
  }

  group('login', () {
    test('a saved session connects and identifies the player', () => run((async) {
          manager.checkLoginStatus();
          async.flushMicrotasks();

          expect(connector.last.sent.single['commandType'], 'PLAYER_INFO_REQUEST');
          expect(connector.last.sent.single['executable']['token'], 'token');
          loggedIn(async, 'alice');
          expect(manager.currentScreen, AppScreenState.mainMenu);
          expect(manager.mySelfPlayer!.nickname, 'alice');
        }));

    test('a new account chooses a nickname until the server accepts one', () => run((async) {
          manager.checkLoginStatus();
          async.flushMicrotasks();
          server(async, 'PLAYER_INFO_RESPONSE',
              {'nickname': '', 'isLogged': false, 'needsNickname': true, 'error': 'NICKNAME_MISSING'});
          expect(manager.currentScreen, AppScreenState.chooseNickname);
          expect(manager.nicknameError, isNull);

          manager.submitNickname('alice');
          async.flushMicrotasks();
          expect(connector.last.sent.last['executable']['nickname'], 'alice');
          server(async, 'PLAYER_INFO_RESPONSE',
              {'nickname': '', 'isLogged': false, 'needsNickname': true, 'error': 'NICKNAME_TAKEN'});
          expect(manager.nicknameError, PlayerInfoResponse.nicknameTaken);

          manager.submitNickname('alice_2');
          async.flushMicrotasks();
          loggedIn(async, 'alice_2');
          expect(manager.currentScreen, AppScreenState.mainMenu);
          expect(manager.nicknameError, isNull);
        }));

    test('a refused token signs the player out', () => run((async) {
          manager.checkLoginStatus();
          async.flushMicrotasks();
          server(async, 'PLAYER_INFO_RESPONSE', {'nickname': '', 'isLogged': false, 'error': 'INVALID_TOKEN'});
          async.flushMicrotasks();

          expect(auth.signedOut, isTrue);
          expect(manager.currentScreen, AppScreenState.login);
          expect(manager.authState, AuthenticationState.unauthenticated);
          expect(manager.authError, isNotNull);
        }));
  });

  group('match', () {
    test('commands carry no player name: the server knows who is on the socket', () => run((async) {
          startMatch(async);
          manager.setBet(1);
          manager.putCard(const CardGame(Seed.CUPS, 1));

          expect(connector.last.sent[connector.last.sent.length - 2], {
            'commandType': 'SET_BET',
            'executable': {'bet': 1},
          });
          expect(connector.last.sent.last, {
            'commandType': 'PUT_CARD',
            'executable': {'seed': 'CUPS', 'value': 1},
          });
        }));

    test('playing a card replaces the hand instead of mutating it', () => run((async) {
          startMatch(async);
          final before = manager.mySelfPlayer!.handCards;

          server(async, 'PLAYED_CARD', {'nickname': 'alice', 'playedCard': card('CUPS', 1)});

          expect(identical(before, manager.mySelfPlayer!.handCards), isFalse);
          expect(manager.mySelfPlayer!.handCards, [const CardGame(Seed.SWORDS, 5)]);
        }));

    test('the finished trick stays on the table and later messages wait their turn', () => run((async) {
          startMatch(async);
          server(async, 'PLAYED_CARD', {'nickname': 'alice', 'playedCard': card('CUPS', 1)});
          server(async, 'PLAYED_CARD', {'nickname': 'bob', 'playedCard': card('CUPS', 2)});
          server(async, 'END_ROUND', {'nextRoundNumber': 1, 'nextPlayerOrderAndTaken': {'alice': 1, 'bob': 0}});
          server(async, 'PLAYER_STATE_UPDATE', {'nickname': 'alice', 'playerState': 'PUT'});

          final alice = manager.game!.playerNamed('alice')!;
          expect(alice.roundsWon, 1);
          expect(alice.playedCard, isNotNull, reason: 'trick still shown');
          expect(alice.playerState, isNot(PlayerState.PUT), reason: 'queued behind the pause');

          async.elapse(displayTime);
          expect(alice.playedCard, isNull);
          expect(alice.playerState, PlayerState.PUT);
          expect(manager.game!.round, 1);
          expect(manager.game!.set, 1, reason: 'a trick does not change the hand size');
        }));

    test('end of set shows the result, then clears bets for the next deal', () => run((async) {
          startMatch(async);
          server(async, 'SETTED_BET', {'nickname': 'alice', 'bet': 1});
          server(async, 'END_SET', {'nextSetNumber': 2, 'nextPlayerOrderAndScore': {'bob': -10, 'alice': 20}});

          expect(manager.lastSetResult, SetResultAnimationState.win);
          expect(manager.game!.playerOrder.map((p) => p.nickname), ['bob', 'alice']);
          expect(manager.game!.set, 2);

          async.elapse(displayTime);
          expect(manager.lastSetResult, SetResultAnimationState.none);
          expect(manager.game!.playerNamed('alice')!.bet, 0);
          expect(manager.game!.playerNamed('alice')!.score, 20);
        }));

    test('logging out during a pause cancels it', () => run((async) {
          startMatch(async);
          server(async, 'END_ROUND', {'nextRoundNumber': 1, 'nextPlayerOrderAndTaken': {'alice': 1, 'bob': 0}});

          manager.logOut();
          async.flushMicrotasks();
          async.elapse(displayTime * 2);

          expect(manager.game, isNull);
          expect(manager.currentScreen, AppScreenState.login);
          expect(connector.connections, hasLength(1), reason: 'no reconnection after logout');
        }));

    test('a server rejection is shown to the player', () => run((async) {
          startMatch(async);
          server(async, 'TEXT_MESSAGE', {'text': 'It is not your turn to play'});

          expect(manager.consumeNotice(), 'It is not your turn to play');
          expect(manager.consumeNotice(), isNull);
        }));
  });

  group('connection loss', () {
    test('a dropped connection reconnects and resumes the match', () => run((async) {
          startMatch(async);
          connector.last.drop();
          async.flushMicrotasks();

          expect(auth.signedOut, isFalse, reason: 'a network drop is not a logout');
          expect(manager.linkState, LinkState.reconnecting);

          async.elapse(const Duration(seconds: 1));
          expect(connector.connections, hasLength(2));
          expect(connector.last.sentTypes, ['PLAYER_INFO_REQUEST']);

          loggedIn(async, 'alice', inMatch: true);
          expect(manager.currentScreen, AppScreenState.inGame);
          server(async, 'STARTING_GAME', {'connectedPlayers': ['bob', 'alice']});
          server(async, 'HAND_UPDATE', {'cards': [card('SWORDS', 5)]});
          server(async, 'INFO_AFTER_RECONNECTION', {
            'set': 4,
            'round': 1,
            'scores': {'alice': 30, 'bob': 10},
            'bets': {'alice': 2, 'bob': 1},
            'roundsWon': {'alice': 1, 'bob': 0},
            'playedCards': {'bob': card('CUPS', 9)},
          });
          server(async, 'PLAYER_STATE_UPDATE', {'nickname': 'alice', 'playerState': 'PUT'});

          final game = manager.game!;
          expect(game.set, 4);
          expect(game.playerNamed('bob')!.playedCard, const CardGame(Seed.CUPS, 9));
          expect(game.playerNamed('alice')!.bet, 2);
          expect(manager.mySelfPlayer!.playerState, PlayerState.PUT);
          expect(manager.linkState, LinkState.connected);
        }));

    test('retries until the server is back', () => run((async) {
          startMatch(async);
          connector.serverDown = true;
          connector.last.drop();
          async.flushMicrotasks();

          async.elapse(const Duration(seconds: 5));
          expect(manager.linkState, LinkState.reconnecting);

          connector.serverDown = false;
          async.elapse(const Duration(seconds: 1));
          expect(manager.linkState, LinkState.connected);
        }));

    test('messages queued behind a login response are not lost', () => run((async) {
          startMatch(async);
          // A pause is running when the reconnection replay arrives
          server(async, 'END_ROUND', {'nextRoundNumber': 1, 'nextPlayerOrderAndTaken': {'alice': 1, 'bob': 0}});
          loggedIn(async, 'alice', inMatch: true);
          server(async, 'STARTING_GAME', {'connectedPlayers': ['alice', 'bob']});
          server(async, 'INFO_AFTER_RECONNECTION', {'set': 2, 'round': 0, 'scores': {'alice': 20}});

          async.elapse(displayTime);
          expect(manager.game, isNotNull);
          expect(manager.game!.set, 2);
          expect(manager.game!.playerNamed('alice')!.score, 20);
        }));

    test('a match that ended while offline returns to the menu', () => run((async) {
          startMatch(async);
          connector.last.drop();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 1));

          loggedIn(async, 'alice', inMatch: false);

          expect(manager.currentScreen, AppScreenState.mainMenu);
          expect(manager.game, isNull);
          expect(manager.consumeNotice(), isNotNull);
        }));
  });
}
