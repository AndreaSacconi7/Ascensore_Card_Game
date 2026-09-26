import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'app_screen_state.dart';
import 'auth/auth_service.dart';
import 'authentication_state.dart';
import 'command/command.dart';
import 'message/briscola_update.dart';
import 'message/end_game.dart';
import 'message/end_round_update.dart';
import 'message/end_set_update.dart';
import 'message/executable_in_client.dart';
import 'message/hand_update.dart';
import 'message/info_after_reconnection.dart';
import 'message/join_game_response.dart';
import 'message/played_card_update.dart';
import 'message/player_exit_game.dart';
import 'message/player_info_response.dart';
import 'message/player_state_update.dart';
import 'message/server_message.dart';
import 'message/setted_bet_update.dart';
import 'message/starting_game.dart';
import 'message/text_message.dart';
import 'message/waiting_room_update.dart';
import 'model/card_game.dart';
import 'model/game.dart';
import 'model/game_rules.dart';
import 'model/my_self_player.dart';
import 'model/player.dart';
import 'model/player_state.dart';
import 'model/set_result_animation_state.dart';
import 'network/game_connection.dart';
import 'network/server_link.dart';

/// Client state and the only entry point to the server.
///
/// Server messages are applied in arrival order from a queue. After a trick or a set the queue pauses for
/// [resultDisplayTime] so players can see the cards before the table is cleared; messages that arrive
/// meanwhile wait their turn instead of being applied out of order.
class ClientManager extends ChangeNotifier {
  ClientManager({
    required AuthService auth,
    required GameConnector connector,
    this.resultDisplayTime = const Duration(seconds: 3),
    List<Duration>? reconnectBackoff,
  }) : _auth = auth {
    _link = ServerLink(
      connector: connector,
      onConnected: _identify,
      onMessage: _onServerText,
      onStateChanged: _onLinkStateChanged,
      backoff: reconnectBackoff ?? ServerLink.defaultBackoff,
    );
  }

  final AuthService _auth;
  late final ServerLink _link;

  /// How long the last trick (or the set result) stays on screen.
  final Duration resultDisplayTime;

  // --- State read by the UI ---

  AppScreenState currentScreen = AppScreenState.login;
  AuthenticationState authState = AuthenticationState.unknown;

  /// Shown once by the login page, then cleared.
  String? authError;

  /// Why the chosen nickname was refused (one of the PlayerInfoResponse error codes).
  String? nicknameError;
  bool submittingNickname = false;

  LinkState linkState = LinkState.closed;

  MySelfPlayer? mySelfPlayer;
  Game? game;
  SetResultAnimationState lastSetResult = SetResultAnimationState.none;

  /// Points this player gained or lost in the set that just ended, shown with [lastSetResult].
  int lastSetDelta = 0;

  /// One-off message for the game screen (a rejected move, a player leaving); cleared when shown.
  String? serverNotice;

  /// Match size the player picked last (2 to 4), also used by "play again".
  int matchSize = 2;

  /// Who is waiting in your match before it starts; null outside matchmaking.
  WaitingRoom? waitingRoom;

  // --- Internals ---

  // Nickname the user chose, sent until the server accepts it
  String? _pendingNickname;

  final Queue<ExecutableInClient> _inbox = Queue();
  Timer? _pauseTimer;

  bool get _isPaused => _pauseTimer != null;

  // ------------------------------------------------------------------
  // Account
  // ------------------------------------------------------------------

  /// Resumes a saved session at startup, if there is one.
  Future<void> checkLoginStatus() async {
    _setAuthState(AuthenticationState.loading);
    final token = await _auth.currentAccessToken();
    if (token == null) {
      _setAuthState(AuthenticationState.unauthenticated);
      return;
    }
    _link.open();
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setAuthState(AuthenticationState.loading);
    try {
      await _auth.signIn(email, password);
      _link.open();
    } catch (e) {
      debugPrint('Sign-in failed: $e');
      _failAuth('Email o password non corretti.');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _setAuthState(AuthenticationState.loading);
    try {
      final token = await _auth.signUp(email, password);
      if (token == null) {
        authError = 'Controlla la tua email per confermare la registrazione, poi accedi.';
        _setAuthState(AuthenticationState.unauthenticated);
        return;
      }
      _link.open();
    } catch (e) {
      debugPrint('Sign-up failed: $e');
      _failAuth('Registrazione non riuscita: controlla l\'email e usa una password di almeno 6 caratteri.');
    }
  }

  /// Sends the chosen public nickname; the answer comes as PLAYER_INFO_RESPONSE.
  void submitNickname(String nickname) {
    _pendingNickname = nickname;
    nicknameError = null;
    submittingNickname = true;
    notifyListeners();
    _identify();
  }

  void clearAuthError() {
    authError = null;
  }

  Future<void> logOut() async {
    _link.send(Command.logout().toJson());
    // Not awaited: the close handshake must not keep the player on this screen
    unawaited(_link.close());
    _resetMatch();
    mySelfPlayer = null;
    _pendingNickname = null;
    nicknameError = null;
    submittingNickname = false;
    currentScreen = AppScreenState.login;
    await _auth.signOut();
    _setAuthState(AuthenticationState.unauthenticated);
  }

  // Runs on every new connection: identifies the player, which also resumes a match in progress
  Future<void> _identify() async {
    final token = await _auth.currentAccessToken();
    if (token == null) {
      // The saved session is gone (signed out elsewhere, or the refresh token expired)
      await logOut();
      return;
    }
    _link.send(Command.playerInfoRequest(token: token, nickname: _pendingNickname ?? '').toJson());
  }

  void _failAuth(String message) {
    authError = message;
    _setAuthState(AuthenticationState.error);
  }

  void _setAuthState(AuthenticationState state) {
    authState = state;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Moves
  // ------------------------------------------------------------------

  /// Enters matchmaking for a match of [players] (the last chosen size if omitted).
  void joinGame({int? players}) {
    matchSize = players ?? matchSize;
    final me = mySelfPlayer?.nickname;
    waitingRoom = WaitingRoom(playersPerMatch: matchSize, players: [if (me != null) me]);
    currentScreen = AppScreenState.inGame;
    notifyListeners();
    _link.send(Command.joinGame(matchSize).toJson());
  }

  /// Leaves matchmaking, or the match in progress for good, and goes back to the menu.
  void leaveGame() {
    final leftMatch = game != null;
    _link.send(Command.leaveGame().toJson());
    backToMenu();
    if (leftMatch) {
      serverNotice = 'Hai abbandonato la partita.';
      notifyListeners();
    }
  }

  /// State changes only when the server confirms with SETTED_BET.
  void setBet(int bet) => _link.send(Command.setBet(bet).toJson());

  /// The card leaves the hand only when the server confirms with PLAYED_CARD.
  void putCard(CardGame card) => _link.send(Command.putCard(card).toJson());

  void backToMenu() {
    _resetMatch();
    currentScreen = AppScreenState.mainMenu;
    notifyListeners();
  }

  /// Returns the pending notice and clears it.
  String? consumeNotice() {
    final notice = serverNotice;
    serverNotice = null;
    return notice;
  }

  // ------------------------------------------------------------------
  // Connection and message queue
  // ------------------------------------------------------------------

  void _onLinkStateChanged(LinkState state) {
    linkState = state;
    if (state == LinkState.reconnecting) {
      // The server replays the full table state after reconnecting: queued updates are stale
      _pauseTimer?.cancel();
      _pauseTimer = null;
      _inbox.clear();
    }
    notifyListeners();
  }

  void _onServerText(String raw) {
    final ExecutableInClient? message;
    try {
      message = decodeServerMessage(raw);
    } catch (e) {
      debugPrint('Unreadable server message: $e');
      return;
    }
    if (message == null) {
      debugPrint('Unknown server message: $raw');
      return;
    }
    _inbox.add(message);
    _drain();
  }

  void _drain() {
    while (!_isPaused && _inbox.isNotEmpty) {
      final message = _inbox.removeFirst();
      try {
        message.execute(clientManager: this);
      } catch (e, stack) {
        debugPrint('Failed to apply ${message.runtimeType}: $e\n$stack');
      }
      notifyListeners();
    }
  }

  /// Holds the queue for [resultDisplayTime], then runs [onResume] and applies what arrived meanwhile.
  void _pauseQueue(VoidCallback onResume) {
    _pauseTimer = Timer(resultDisplayTime, () {
      _pauseTimer = null;
      onResume();
      notifyListeners();
      _drain();
    });
  }

  // Leaving the match from the UI: also drops queued messages and any pending pause
  void _resetMatch() {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    _inbox.clear();
    _clearMatchState();
    serverNotice = null;
    waitingRoom = null;
  }

  // Safe inside a message handler: never touches the queue, which may hold the messages that follow
  void _clearMatchState() {
    game = null;
    lastSetResult = SetResultAnimationState.none;
  }

  // ------------------------------------------------------------------
  // Server messages (applied by the queue, in order)
  // ------------------------------------------------------------------

  void handlePlayerInfo(PlayerInfoResponse response) {
    submittingNickname = false;
    if (response.isLogged) {
      _pendingNickname = null;
      nicknameError = null;
      authState = AuthenticationState.authenticated;
      final wasPlaying = currentScreen == AppScreenState.inGame && game != null;
      _clearMatchState();
      mySelfPlayer = MySelfPlayer(response.nickname);
      if (response.inMatch) {
        // Reconnected to a match in progress: STARTING_GAME and the table state follow
        currentScreen = AppScreenState.inGame;
      } else {
        if (wasPlaying) {
          serverNotice = 'La partita è terminata mentre eri disconnesso.';
        }
        currentScreen = AppScreenState.mainMenu;
      }
    } else if (response.needsNickname) {
      authState = AuthenticationState.authenticated;
      nicknameError = response.error == PlayerInfoResponse.nicknameMissing ? null : response.error;
      currentScreen = AppScreenState.chooseNickname;
    } else {
      // Token refused: the session is no longer valid
      authError = 'Sessione scaduta, accedi di nuovo.';
      unawaited(logOut());
    }
  }

  void handleJoinGameResponse(JoinGameResponse response) {
    if (!response.isJoined) {
      serverNotice = 'Impossibile entrare in partita, riprova.';
      waitingRoom = null;
      currentScreen = AppScreenState.mainMenu;
      return;
    }
    matchSize = response.playersPerMatch;
  }

  void handleWaitingRoomUpdate(WaitingRoomUpdate update) {
    // Late updates after the match started (or after leaving) are ignored
    if (game != null || currentScreen != AppScreenState.inGame) return;
    waitingRoom = WaitingRoom(playersPerMatch: update.playersPerMatch, players: update.players);
  }

  void handleStartingGame(StartingGame message) {
    final me = mySelfPlayer;
    if (me == null) return;
    me
      ..handCards = const []
      ..score = 0
      ..bet = 0
      ..hasBet = false
      ..roundsWon = 0
      ..playedCard = null;
    final players =
        message.connectedPlayers.map((nickname) => nickname == me.nickname ? me : Player(nickname)).toList();
    game = Game(players, maxHandSize: message.maxHandSize);
    waitingRoom = null;
    currentScreen = AppScreenState.inGame;
  }

  void handleHandUpdate(HandUpdate message) {
    mySelfPlayer?.handCards = List.unmodifiable(message.handCards);
  }

  void handleBriscolaUpdate(BriscolaUpdate message) {
    game?.briscola = message.briscolaCard;
  }

  void handlePlayerStateUpdate(PlayerStateUpdate message) {
    game?.playerNamed(message.nickname)?.playerState = message.playerState;
  }

  void handleSettedBet(SettedBetUpdate message) {
    game?.playerNamed(message.nickname)
      ?..bet = message.bet
      ..hasBet = true;
  }

  void handlePlayedCard(PlayedCardUpdate message) {
    final player = game?.playerNamed(message.nickname);
    if (player == null) return;
    player.playedCard = message.playedCard;
    if (player == mySelfPlayer) {
      mySelfPlayer!.removeCardFromHand(message.playedCard);
    }
    _markTrickWinner();
  }

  // Once everyone has played, highlight who takes the trick while it stays on the table.
  // END_ROUND confirms it; the last trick of a set is only followed by END_SET, which does not say.
  void _markTrickWinner() {
    final game = this.game!;
    final inPlay = game.playerOrder.where((p) => p.playerState != PlayerState.EXIT).toList();
    if (inPlay.isEmpty || inPlay.any((p) => p.playedCard == null)) return;
    final trick = inPlay.map((p) => p.playedCard!).toList();
    game.trickWinner = inPlay[GameRules.trickWinnerIndex(trick, game.briscola?.seed)].nickname;
  }

  void handleEndRoundUpdate(EndRoundUpdate message) {
    final game = this.game;
    if (game == null) return;
    message.nextPlayerOrderAndTaken.forEach((nickname, taken) {
      game.playerNamed(nickname)?.roundsWon = taken;
    });
    game.playerOrder = game.playersInOrder(message.nextPlayerOrderAndTaken.keys);
    game.round = message.nextRoundNumber;
    // The winner leads the next trick, so comes first
    game.trickWinner = message.nextPlayerOrderAndTaken.keys.firstOrNull;

    // Keep the finished trick on the table for a moment
    _pauseQueue(() {
      for (final p in game.players) {
        p.playedCard = null;
      }
      game.trickWinner = null;
    });
  }

  void handleEndSetUpdate(EndSetUpdate message) {
    final game = this.game;
    final me = mySelfPlayer;
    if (game == null || me == null) return;

    final myNewScore = message.nextPlayerOrderAndScore[me.nickname];
    if (myNewScore != null) {
      // An exact bet always gains points, a missed one always loses them
      lastSetDelta = myNewScore - me.score;
      lastSetResult = lastSetDelta > 0 ? SetResultAnimationState.win : SetResultAnimationState.loss;
    }
    message.nextPlayerOrderAndScore.forEach((nickname, score) {
      game.playerNamed(nickname)?.score = score;
    });
    game.playerOrder = game.playersInOrder(message.nextPlayerOrderAndScore.keys);
    game.set = message.nextSetNumber;
    game.setsPlayed = message.setsPlayed ?? game.setsPlayed + 1;
    game.round = 0;

    // Show the last trick and the set result, then clear the table for the next deal
    _pauseQueue(() {
      for (final p in game.players) {
        p
          ..playedCard = null
          ..bet = 0
          ..hasBet = false
          ..roundsWon = 0;
      }
      game.trickWinner = null;
      lastSetResult = SetResultAnimationState.none;
    });
  }

  void handleEndGame(EndGame message) {
    final game = this.game;
    if (game == null) return;
    message.gameResult.forEach((nickname, score) {
      game.playerNamed(nickname)?.score = score;
    });
    currentScreen = AppScreenState.gameOver;
  }

  /// The player is out for good: the server has taken their card off the table and out of the turn order.
  void handlePlayerExitGame(PlayerExitGame message) {
    final game = this.game;
    final player = game?.playerNamed(message.nickname);
    if (game == null || player == null) return;
    player
      ..playerState = PlayerState.EXIT
      ..playedCard = null;
    game.playerOrder = game.playerOrder.where((p) => p != player).toList();
    if (game.trickWinner == player.nickname) game.trickWinner = null;
    serverNotice = '${message.nickname} ha abbandonato la partita.';
  }

  void handleTextMessage(TextMessage message) {
    serverNotice = message.text;
  }

  void handleInfoAfterReconnection(InfoAfterReconnection message) {
    final game = this.game;
    if (game == null) return;
    game
      ..set = message.set
      ..round = message.round
      ..setsPlayed = message.setsPlayed
      ..maxHandSize = message.maxHandSize;
    // A bet of 0 looks like no bet: once cards are being played, everyone has bet
    final bettingOver = message.round > 0 || message.playedCards.isNotEmpty;
    for (final p in game.players) {
      final bet = message.bets[p.nickname] ?? 0;
      p
        ..score = message.scores[p.nickname] ?? p.score
        ..bet = bet
        ..hasBet = bettingOver || bet > 0
        ..roundsWon = message.roundsWon[p.nickname] ?? 0
        ..playedCard = message.playedCards[p.nickname];
    }
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    unawaited(_link.close());
    super.dispose();
  }
}

/// Players waiting for a match to fill up.
class WaitingRoom {
  final int playersPerMatch;
  final List<String> players;

  const WaitingRoom({required this.playersPerMatch, required this.players});

  int get missing => (playersPerMatch - players.length).clamp(0, playersPerMatch);
}
