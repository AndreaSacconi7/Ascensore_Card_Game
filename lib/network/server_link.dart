import 'dart:async';

import 'package:flutter/foundation.dart';

import 'game_connection.dart';

enum LinkState { closed, connecting, connected, reconnecting }

/// Keeps the connection to the game server open: reconnects with backoff when it drops, until [close].
///
/// A dropped connection is not a logout: the server keeps the player's seat for 60 seconds, and
/// [onConnected] runs again on every new connection so the client can identify itself and resume.
///
/// Heartbeat: while connected, [heartbeatMessage] is sent every [heartbeatInterval] and the server answers.
/// A connection that stays silent for [missedBeatsAllowed] intervals is treated as dropped: networks often
/// lose a connection without ever reporting it (a phone switching from Wi-Fi to mobile data).
class ServerLink {
  ServerLink({
    required GameConnector connector,
    required this.onConnected,
    required this.onMessage,
    required this.onStateChanged,
    this.backoff = defaultBackoff,
    this.heartbeatMessage,
    this.heartbeatInterval = const Duration(seconds: 10),
    this.missedBeatsAllowed = 2,
  }) : _connector = connector;

  static const defaultBackoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];

  final GameConnector _connector;
  final void Function() onConnected;
  final void Function(String text) onMessage;
  final void Function(LinkState state) onStateChanged;

  /// Delays between attempts; the last one repeats.
  final List<Duration> backoff;

  /// Sent every [heartbeatInterval] while connected; null disables the heartbeat.
  final String? heartbeatMessage;
  final Duration heartbeatInterval;
  final int missedBeatsAllowed;

  Timer? _heartbeat;
  bool _heardSinceLastBeat = true;
  int _missedBeats = 0;

  LinkState _state = LinkState.closed;
  LinkState get state => _state;

  GameConnection? _connection;
  StreamSubscription<String>? _subscription;
  Timer? _retryTimer;
  int _failedAttempts = 0;

  // Bumped by close(), so an attempt that was in flight does not revive a closed link
  int _generation = 0;

  /// Connects if not already connected or connecting.
  void open() {
    if (_state != LinkState.closed) return;
    _connect(_generation, LinkState.connecting);
  }

  /// Sends if connected; commands sent while offline are dropped (the server state wins on reconnect).
  void send(String text) {
    if (_state != LinkState.connected) {
      debugPrint('Not connected, command dropped');
      return;
    }
    _connection!.send(text);
  }

  /// Stops reconnecting and closes the connection. The link is closed as soon as this is called;
  /// the returned future only tracks the close handshake, which can hang on a dead network.
  Future<void> close() async {
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _stopHeartbeat();
    _failedAttempts = 0;
    final subscription = _subscription;
    final connection = _connection;
    _subscription = null;
    _connection = null;
    _setState(LinkState.closed);
    await subscription?.cancel();
    await connection?.close();
  }

  Future<void> _connect(int generation, LinkState stateWhileConnecting) async {
    _setState(stateWhileConnecting);
    try {
      final connection = await _connector();
      if (generation != _generation) {
        await connection.close();
        return;
      }
      _connection = connection;
      _failedAttempts = 0;
      _subscription = connection.incoming.listen(
        (text) {
          _heardSinceLastBeat = true;
          onMessage(text);
        },
        onError: (Object error) => debugPrint('Connection error: $error'),
        onDone: () => _onDropped(generation),
      );
      _setState(LinkState.connected);
      _startHeartbeat(generation);
      onConnected();
    } catch (error) {
      debugPrint('Could not connect: $error');
      if (generation == _generation) {
        _scheduleRetry(generation);
      }
    }
  }

  void _onDropped(int generation) {
    if (generation != _generation) return;
    _stopHeartbeat();
    _subscription = null;
    _connection = null;
    _scheduleRetry(generation);
  }

  void _startHeartbeat(int generation) {
    final message = heartbeatMessage;
    if (message == null) return;
    _heardSinceLastBeat = true;
    _missedBeats = 0;
    _heartbeat = Timer.periodic(heartbeatInterval, (_) {
      if (generation != _generation || _state != LinkState.connected) return;
      _missedBeats = _heardSinceLastBeat ? 0 : _missedBeats + 1;
      _heardSinceLastBeat = false;
      if (_missedBeats >= missedBeatsAllowed) {
        debugPrint('No answer from the server, reconnecting');
        final subscription = _subscription;
        final connection = _connection;
        _onDropped(generation);
        unawaited(subscription?.cancel());
        unawaited(connection?.close());
        return;
      }
      _connection?.send(message);
    });
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void _scheduleRetry(int generation) {
    _setState(LinkState.reconnecting);
    final delay = backoff[_failedAttempts.clamp(0, backoff.length - 1)];
    _failedAttempts++;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (generation == _generation) {
        _connect(generation, LinkState.reconnecting);
      }
    });
  }

  void _setState(LinkState state) {
    if (state == _state) return;
    _state = state;
    onStateChanged(state);
  }
}
