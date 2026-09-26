import 'dart:convert';

import 'package:ascensore_client/message/briscola_update.dart';
import 'package:ascensore_client/message/end_round_update.dart';
import 'package:ascensore_client/message/info_after_reconnection.dart';
import 'package:ascensore_client/message/player_info_response.dart';
import 'package:ascensore_client/message/player_state_update.dart';
import 'package:ascensore_client/message/server_message.dart';
import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player_state.dart';
import 'package:ascensore_client/model/seed.dart';
import 'package:flutter_test/flutter_test.dart';

String message(String type, Map<String, dynamic> executable) =>
    jsonEncode({'messageType': type, 'executable': executable});

void main() {
  test('every message type the server sends has a decoder', () {
    const samples = {
      'PLAYER_INFO_RESPONSE': {'nickname': 'alice', 'isLogged': true, 'needsNickname': false, 'inMatch': false},
      'JOIN_GAME_RESPONSE': {'nickname': 'alice', 'isJoined': true},
      'STARTING_GAME': {'connectedPlayers': ['alice', 'bob']},
      'HAND_UPDATE': {'cards': [{'seed': 'CUPS', 'value': 1}]},
      'BRISCOLA_UPDATE': {'briscolaCard': {'seed': 'COINS', 'value': 7}},
      'PLAYER_STATE_UPDATE': {'nickname': 'alice', 'playerState': 'BET'},
      'SETTED_BET': {'nickname': 'alice', 'bet': 1},
      'PLAYED_CARD': {'nickname': 'alice', 'playedCard': {'seed': 'CUPS', 'value': 1}},
      'END_ROUND': {'nextRoundNumber': 1, 'nextPlayerOrderAndTaken': {'bob': 1, 'alice': 0}},
      'END_SET': {'nextSetNumber': 2, 'nextPlayerOrderAndScore': {'bob': 20, 'alice': -10}},
      'END_GAME': {'gameResult': {'bob': 120, 'alice': 80}},
      'PLAYER_EXIT_GAME': {'nickname': 'bob'},
      'TEXT_MESSAGE': {'text': 'It is not your turn to play'},
      'INFO_AFTER_RECONNECTION': {'set': 3, 'round': 1, 'scores': {}, 'bets': {}, 'roundsWon': {}, 'playedCards': {}},
    };
    samples.forEach((type, executable) {
      expect(decodeServerMessage(message(type, executable)), isNotNull, reason: type);
    });
  });

  test('unknown message types are ignored', () {
    expect(decodeServerMessage(message('SOMETHING_NEW', {})), isNull);
  });

  test('briscola is absent at the start of the peak set', () {
    final update = decodeServerMessage(message('BRISCOLA_UPDATE', {})) as BriscolaUpdate;
    expect(update.briscolaCard, isNull);
  });

  test('player order keeps the server key order', () {
    final update = decodeServerMessage(message('END_ROUND', {
      'nextRoundNumber': 2,
      'nextPlayerOrderAndTaken': {'zoe': 2, 'alice': 0, 'mario': 1},
    })) as EndRoundUpdate;
    expect(update.nextPlayerOrderAndTaken.keys, ['zoe', 'alice', 'mario']);
  });

  test('player info response defaults missing flags', () {
    final response = decodeServerMessage(message('PLAYER_INFO_RESPONSE', {
      'nickname': '',
      'isLogged': false,
      'needsNickname': true,
      'error': 'NICKNAME_TAKEN',
    })) as PlayerInfoResponse;
    expect(response.needsNickname, isTrue);
    expect(response.inMatch, isFalse);
    expect(response.error, PlayerInfoResponse.nicknameTaken);
  });

  test('EXIT is a known player state', () {
    final update = decodeServerMessage(message('PLAYER_STATE_UPDATE', {'nickname': 'bob', 'playerState': 'EXIT'}))
        as PlayerStateUpdate;
    expect(update.playerState, PlayerState.EXIT);
  });

  test('reconnection info carries the cards on the table', () {
    final info = decodeServerMessage(message('INFO_AFTER_RECONNECTION', {
      'set': 4,
      'round': 2,
      'scores': {'alice': 30},
      'bets': {'alice': 1},
      'roundsWon': {'alice': 1},
      'playedCards': {'bob': {'seed': 'SWORDS', 'value': 3}},
    })) as InfoAfterReconnection;
    expect(info.set, 4);
    expect(info.playedCards['bob'], const CardGame(Seed.SWORDS, 3));
  });
}
