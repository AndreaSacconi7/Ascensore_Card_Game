import 'package:flutter/foundation.dart';
import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player_state.dart';

/// A player at the table. Counters are [ValueNotifier]s so each widget rebuilds only for its own value.
class Player {
  final String nickname;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> betNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> roundsWonNotifier = ValueNotifier<int>(0);
  final ValueNotifier<CardGame?> playedCardNotifier = ValueNotifier<CardGame?>(null);
  PlayerState playerState = PlayerState.IDLE;

  /// A computer opponent in an offline match.
  bool isBot = false;

  /// Whether this player has already bet in the current set (a bet of 0 is still a bet).
  bool hasBet = false;

  /// While it is this player's turn: when it runs out, and how long a full turn is. Null without a limit.
  DateTime? turnDeadline;
  Duration? turnLength;

  Player(this.nickname);

  int get score => scoreNotifier.value;
  set score(int value) => scoreNotifier.value = value;

  int get bet => betNotifier.value;
  set bet(int value) => betNotifier.value = value;

  /// Tricks taken in the current set.
  int get roundsWon => roundsWonNotifier.value;
  set roundsWon(int value) => roundsWonNotifier.value = value;

  /// Card this player has on the table in the current trick, if any.
  CardGame? get playedCard => playedCardNotifier.value;
  set playedCard(CardGame? card) => playedCardNotifier.value = card;
}
