import '../../model/game.dart';
import '../../model/player.dart';
import '../../model/player_state.dart';

/// Opponents in seating order starting from the player after you, so the table reads clockwise.
List<Player> opponentsFrom(Game game, Player me) {
  final seats = game.players;
  final myIndex = seats.indexOf(me);
  if (myIndex < 0) return seats.where((p) => p != me).toList();
  return [for (var i = 1; i < seats.length; i++) seats[(myIndex + i) % seats.length]];
}

bool isOnTurn(Player player) => player.playerState == PlayerState.BET || player.playerState == PlayerState.PUT;
