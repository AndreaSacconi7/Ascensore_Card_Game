import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../model/card_game.dart';
import '../model/game_rules.dart';
import '../model/seed.dart';
import 'bot.dart';

/// A match against computer opponents that runs on the device, with no server.
///
/// It follows the same rules as the server and speaks the same protocol: it receives the commands the
/// client would send (as JSON) and answers with the same messages, so the client's state, queue and screens
/// work unchanged. Bots think for [botDelay] before acting, and wait longer after a trick while the client
/// keeps the cards on screen.
class LocalMatch {
  LocalMatch({
    required String human,
    required List<String> botNames,
    required this.onMessage,
    this.maxHandSize = 10,
    Random? random,
    this.botDelay = const Duration(milliseconds: 900),
    this.resultDisplay = const Duration(seconds: 3),
  })  : _random = random ?? Random(),
        _brain = BotBrain(random) {
    _seats = [
      _Seat(human, isBot: false),
      for (final name in botNames) _Seat(name, isBot: true),
    ];
    _order = List.of(_seats);
  }

  /// Receives every message for the human player, as the server would send it.
  final void Function(String json) onMessage;

  final int maxHandSize;
  final Duration botDelay;
  final Duration resultDisplay;

  final Random _random;
  final BotBrain _brain;

  late final List<_Seat> _seats;
  late List<_Seat> _order;
  int _setIndex = 0;
  int _round = 0;
  int _betsPlaced = 0;
  final List<CardGame> _trick = [];
  CardGame? _briscola;
  Timer? _botTimer;
  bool _over = false;

  int get _handSize => GameRules.handSize(_setIndex, maxHandSize);
  bool get _isPeakSet => _handSize == maxHandSize;
  int get _totalSets => 2 * maxHandSize - 1;

  void start() {
    _emit('STARTING_GAME', {'connectedPlayers': _names(_order), 'maxHandSize': maxHandSize});
    _deal();
    _emitHandAndBriscola();
    for (final seat in _seats) {
      seat.state = 'WAIT';
      _emit('PLAYER_STATE_UPDATE', {'nickname': seat.name, 'playerState': 'WAIT'});
    }
    _giveTurn(_order.first, 'BET');
  }

  /// A command from the human player, as JSON (SET_BET, PUT_CARD, LEAVE_GAME_REQUEST).
  void receive(String json) {
    if (_over) return;
    final command = jsonDecode(json) as Map<String, dynamic>;
    final executable = command['executable'] as Map<String, dynamic>? ?? const {};
    final human = _seats.first;
    switch (command['commandType']) {
      case 'SET_BET':
        _setBet(human, executable['bet'] as int);
      case 'PUT_CARD':
        _putCard(human, CardGame(Seed.values.byName(executable['seed'] as String), executable['value'] as int));
      case 'LEAVE_GAME_REQUEST':
        dispose();
    }
  }

  void dispose() {
    _over = true;
    _botTimer?.cancel();
  }

  ///// Moves /////

  void _setBet(_Seat seat, int bet) {
    if (seat.state != 'BET') {
      _reject(seat, 'Non è il tuo turno di scommettere');
      return;
    }
    final isLast = _betsPlaced == _seats.length - 1;
    final others = _seats.fold<int>(0, (sum, s) => sum + s.bet);
    final valid = bet >= 0 && bet <= _handSize && (!isLast || others + bet != _handSize);
    if (!valid) {
      _reject(seat, 'Scommessa non valida');
      return;
    }
    seat.bet = bet;
    _betsPlaced++;
    _emit('SETTED_BET', {'nickname': seat.name, 'bet': bet});
    _endTurn(seat);
    if (_betsPlaced < _seats.length) {
      _giveTurn(_order[_betsPlaced], 'BET');
    } else {
      _giveTurn(_order.first, 'PUT');
    }
  }

  void _putCard(_Seat seat, CardGame card) {
    if (seat.state != 'PUT') {
      _reject(seat, 'Non è il tuo turno');
      return;
    }
    if (!seat.hand.contains(card)) {
      _reject(seat, 'Non hai questa carta');
      return;
    }
    final lead = _trick.isEmpty ? null : _trick.first;
    if (!GameRules.isValidCard(leadCard: lead, hand: seat.hand, card: card)) {
      _reject(seat, 'Devi rispondere al seme della prima carta');
      return;
    }
    if (lead == null && _isPeakSet) {
      // Peak set: the card leading the trick sets the briscola
      _briscola = card;
      _emit('BRISCOLA_UPDATE', {'briscolaCard': _cardJson(card)});
    }
    _trick.add(card);
    seat.hand.remove(card);
    _emit('PLAYED_CARD', {'nickname': seat.name, 'playedCard': _cardJson(card)});
    _endTurn(seat);
    if (_trick.length < _seats.length) {
      _giveTurn(_order[_trick.length], 'PUT');
    } else {
      _completeTrick();
    }
  }

  void _completeTrick() {
    final winner = _order[GameRules.trickWinnerIndex(_trick, _briscola?.seed)];
    winner.tricks++;
    _round++;
    if (_round == _handSize) {
      _completeSet();
      return;
    }
    _trick.clear();
    _rotateTo(winner);
    if (_isPeakSet) {
      _briscola = null;
      _emit('BRISCOLA_UPDATE', {});
    }
    _emit('END_ROUND', {
      'nextRoundNumber': _round,
      'nextPlayerOrderAndTaken': {for (final s in _order) s.name: s.tricks},
    });
    _giveTurn(_order.first, 'PUT', afterResult: true);
  }

  void _completeSet() {
    for (final seat in _seats) {
      seat.score += GameRules.setScore(seat.bet, seat.tricks);
    }
    if (_setIndex == _totalSets - 1) {
      _endMatch();
      return;
    }
    _setIndex++;
    _round = 0;
    _betsPlaced = 0;
    _trick.clear();
    for (final seat in _seats) {
      seat
        ..bet = 0
        ..tricks = 0;
    }
    // Who bets first moves one seat round the table every set
    _rotateTo(_seats[_setIndex % _seats.length]);
    _deal();
    _emit('END_SET', {
      'nextSetNumber': _handSize,
      'setsPlayed': _setIndex,
      'nextPlayerOrderAndScore': {for (final s in _order) s.name: s.score},
    });
    _emitHandAndBriscola();
    _giveTurn(_order.first, 'BET', afterResult: true);
  }

  void _endMatch() {
    final standing = List.of(_seats)..sort((a, b) => b.score.compareTo(a.score));
    _emit('END_GAME', {
      'gameResult': {for (final s in standing) s.name: s.score},
    });
    dispose();
  }

  ///// Turns /////

  void _giveTurn(_Seat seat, String state, {bool afterResult = false}) {
    seat.state = state;
    _emit('PLAYER_STATE_UPDATE', {'nickname': seat.name, 'playerState': state});
    if (seat.isBot) {
      _botTimer?.cancel();
      _botTimer = Timer(botDelay + (afterResult ? resultDisplay : Duration.zero), () => _botPlays(seat));
    }
  }

  void _endTurn(_Seat seat) {
    seat.state = 'WAIT';
    _emit('PLAYER_STATE_UPDATE', {'nickname': seat.name, 'playerState': 'WAIT'});
  }

  void _botPlays(_Seat bot) {
    if (_over) return;
    if (bot.state == 'BET') {
      final isLast = _betsPlaced == _seats.length - 1;
      final others = _seats.fold<int>(0, (sum, s) => sum + s.bet);
      final forbidden = isLast && _handSize - others >= 0 ? _handSize - others : null;
      _setBet(bot,
          _brain.chooseBet(hand: bot.hand, briscola: _briscola?.seed, players: _seats.length, forbidden: forbidden));
    } else if (bot.state == 'PUT') {
      _putCard(
          bot,
          _brain.chooseCard(
              hand: bot.hand, trick: _trick, briscola: _briscola?.seed, tricksNeeded: bot.bet - bot.tricks));
    }
  }

  ///// Helpers /////

  void _deal() {
    final deck = [
      for (final seed in Seed.values)
        for (var value = 1; value <= 10; value++) CardGame(seed, value),
    ]..shuffle(_random);
    for (final seat in _seats) {
      seat.hand = deck.sublist(0, _handSize);
      deck.removeRange(0, _handSize);
    }
    _briscola = deck.isNotEmpty && !_isPeakSet ? deck.first : null;
  }

  void _emitHandAndBriscola() {
    _emit('HAND_UPDATE', {'cards': _seats.first.hand.map(_cardJson).toList()});
    _emit('BRISCOLA_UPDATE', {if (_briscola != null) 'briscolaCard': _cardJson(_briscola!)});
  }

  // The order rotates so that [first] acts first, keeping the seating order
  void _rotateTo(_Seat first) {
    final start = _order.indexOf(first);
    _order = [..._order.sublist(start), ..._order.sublist(0, start)];
  }

  void _reject(_Seat seat, String text) {
    if (!seat.isBot) _emit('TEXT_MESSAGE', {'text': text});
  }

  List<String> _names(List<_Seat> seats) => seats.map((s) => s.name).toList();

  Map<String, dynamic> _cardJson(CardGame card) => {'seed': card.seed.name, 'value': card.value};

  // Delivered after the current call returns, in order, like messages from a socket
  void _emit(String type, Map<String, dynamic> executable) {
    final json = jsonEncode({'messageType': type, 'executable': executable});
    scheduleMicrotask(() => onMessage(json));
  }
}

class _Seat {
  _Seat(this.name, {required this.isBot});

  final String name;
  final bool isBot;
  List<CardGame> hand = [];
  int bet = 0;
  int tricks = 0;
  int score = 0;
  String state = 'IDLE';
}
