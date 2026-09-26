import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player.dart';

/// The client's copy of the match, updated only by server messages.
class Game {
  /// Players in seating order, as sent in STARTING_GAME.
  final List<Player> players;

  /// Order of play for the current trick (betting order at the start of a set).
  List<Player> playerOrder;

  CardGame? briscola;

  /// Hand size of the current set; the protocol calls it the set number.
  int set = 1;

  /// Tricks completed in the current set.
  int round = 0;

  Game(this.players) : playerOrder = List.of(players);

  Player? playerNamed(String nickname) {
    for (final p in players) {
      if (p.nickname == nickname) return p;
    }
    return null;
  }

  /// Players named by [nicknames], in that order; unknown names are skipped.
  List<Player> playersInOrder(Iterable<String> nicknames) =>
      nicknames.map(playerNamed).whereType<Player>().toList();
}
