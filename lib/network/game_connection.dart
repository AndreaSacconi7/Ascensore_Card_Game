import 'package:web_socket_channel/web_socket_channel.dart';

/// One open connection to the game server.
abstract class GameConnection {
  /// Text frames from the server; the stream ends when the connection drops.
  Stream<String> get incoming;

  void send(String text);

  Future<void> close();
}

/// Opens a connection, or throws if the server cannot be reached.
typedef GameConnector = Future<GameConnection> Function();

class WebSocketGameConnection implements GameConnection {
  final WebSocketChannel _channel;

  WebSocketGameConnection._(this._channel);

  static Future<GameConnection> connect(Uri uri) async {
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    return WebSocketGameConnection._(channel);
  }

  @override
  Stream<String> get incoming => _channel.stream.map((frame) => frame as String);

  @override
  void send(String text) => _channel.sink.add(text);

  @override
  Future<void> close() => _channel.sink.close();
}
