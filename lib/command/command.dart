import 'dart:convert';

import '../model/card_game.dart';

/// Client-to-server commands: {"commandType": ..., "executable": {...}}.
/// The server identifies the player by the socket, so commands carry no player name.
class Command {
  final String commandType;
  final Map<String, dynamic> executable;

  const Command._(this.commandType, [this.executable = const {}]);

  /// First command on every socket. [nickname] is only read by the server when the account has none yet.
  factory Command.playerInfoRequest({required String token, String nickname = ''}) =>
      Command._('PLAYER_INFO_REQUEST', {'token': token, 'nickname': nickname});

  /// Enter matchmaking for a match of [players] (2 to 4).
  factory Command.joinGame(int players) => Command._('JOIN_GAME_REQUEST', {'players': players});

  factory Command.leaveGame() => const Command._('LEAVE_GAME_REQUEST');

  factory Command.setBet(int bet) => Command._('SET_BET', {'bet': bet});

  factory Command.putCard(CardGame card) => Command._('PUT_CARD', {'seed': card.seed.name, 'value': card.value});

  factory Command.logout() => const Command._('LOGOUT');

  /// Heartbeat; the server answers with PONG.
  factory Command.ping() => const Command._('PING');

  String toJson() => jsonEncode({'commandType': commandType, 'executable': executable});
}
