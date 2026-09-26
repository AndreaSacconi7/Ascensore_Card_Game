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

  /// Largest hand of the match: hands go 1..maxHandSize..1.
  int maxHandSize;

  /// Sets completed before the current one.
  int setsPlayed = 0;

  /// Who takes the trick on the table, while it is shown before being cleared.
  String? trickWinner;

  Game(this.players, {this.maxHandSize = 10}) : playerOrder = List.of(players);

  /// Position of the current set in the match, from 1 to [totalSets].
  int get setNumber => setsPlayed + 1;

  int get totalSets => 2 * maxHandSize - 1;

  /// The hand size is still growing (the elevator goes up).
  bool get goingUp => setNumber < maxHandSize;

  /// The set with the largest hand: the card leading each trick sets the briscola.
  bool get isPeakSet => set == maxHandSize;

  Player? playerNamed(String nickname) {
    for (final p in players) {
      if (p.nickname == nickname) return p;
    }
    return null;
  }

  /// Players named by [nicknames], in that order; unknown names are skipped.
  List<Player> playersInOrder(Iterable<String> nicknames) => nicknames.map(playerNamed).whereType<Player>().toList();
}
