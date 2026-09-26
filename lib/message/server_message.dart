import 'dart:convert';

import 'briscola_update.dart';
import 'end_game.dart';
import 'end_round_update.dart';
import 'end_set_update.dart';
import 'executable_in_client.dart';
import 'hand_update.dart';
import 'info_after_reconnection.dart';
import 'join_game_response.dart';
import 'played_card_update.dart';
import 'player_exit_game.dart';
import 'player_info_response.dart';
import 'player_state_update.dart';
import 'setted_bet_update.dart';
import 'starting_game.dart';
import 'text_message.dart';

typedef _Decoder = ExecutableInClient Function(Map<String, dynamic> executable);

/// Decoders for every server message, keyed by messageType. See the server's docs/protocol.md.
final Map<String, _Decoder> _decoders = {
  'PLAYER_INFO_RESPONSE': PlayerInfoResponse.fromJson,
  'JOIN_GAME_RESPONSE': JoinGameResponse.fromJson,
  'STARTING_GAME': StartingGame.fromJson,
  'HAND_UPDATE': HandUpdate.fromJson,
  'BRISCOLA_UPDATE': BriscolaUpdate.fromJson,
  'PLAYER_STATE_UPDATE': PlayerStateUpdate.fromJson,
  'SETTED_BET': SettedBetUpdate.fromJson,
  'PLAYED_CARD': PlayedCardUpdate.fromJson,
  'END_ROUND': EndRoundUpdate.fromJson,
  'END_SET': EndSetUpdate.fromJson,
  'END_GAME': EndGame.fromJson,
  'PLAYER_EXIT_GAME': PlayerExitGame.fromJson,
  'TEXT_MESSAGE': TextMessage.fromJson,
  'INFO_AFTER_RECONNECTION': InfoAfterReconnection.fromJson,
};

/// Parses {"messageType": ..., "executable": {...}}; returns null for unknown types.
ExecutableInClient? decodeServerMessage(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final decoder = _decoders[json['messageType']];
  if (decoder == null) {
    return null;
  }
  return decoder(json['executable'] as Map<String, dynamic>? ?? const {});
}
