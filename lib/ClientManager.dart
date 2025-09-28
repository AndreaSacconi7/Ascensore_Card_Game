import 'dart:async';
import 'dart:collection';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/message/Message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ClientManager {
  final Queue<Message> _messageQueue = Queue<Message>();
  final _condition = Condition();
  bool _isRunning = false;
  late final Stream _stream;

  ClientManager(WebSocketChannel channel) {
    _stream = channel.stream.asBroadcastStream();
    _stream.listen(_handleMessage);
    _startProcessing();
  }

  void _handleMessage(dynamic message) {
    // Gestisci i messaggi in arrivo dal server WebSocket
    print('Message from server: $message');

    enqueueMessage(message);
    // Puoi aggiornare lo stato del widget in base ai messaggi ricevuti
  }

  // Add a message to the queue
  void enqueueMessage(Message message) {
    _messageQueue.add(message);
    _condition.notify(); // Notify the processing thread
  }

  // Start processing messages in a separate thread
  void _startProcessing() {
    _isRunning = true;
    Future(() async {
      while (_isRunning) {
        Message? message;
        await _condition.synchronized(() async {
          while (_messageQueue.isEmpty && _isRunning) {
            await _condition.wait(); // Wait until a message is added
          }
          if (_isRunning) {
            message = _messageQueue.removeFirst();
          }
        });
        message?.execute();
      }
    });
  }

  // Stop the processing thread
  void stop() {
    _isRunning = false;
    _condition.notify(); // Wake up the thread to exit
  }
}

class Condition {
  final _lock = Object();
  final _completers = <Completer<void>>[];

  Future<void> synchronized(Future<void> Function() action) async {
    return Future.sync(() => action());
  }

  Future<void> wait() {
    final completer = Completer<void>();
    _completers.add(completer);
    return completer.future;
  }

  void notify() {
    if (_completers.isNotEmpty) {
      _completers.removeAt(0).complete();
    }
  }
}