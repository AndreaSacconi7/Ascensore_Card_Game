import 'dart:async';
import 'dart:collection';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/message/Message.dart';


class ClientManager {
  final Queue<Message> _messageQueue = Queue<Message>();
  final _condition = Condition();
  bool _isRunning = false;

  ClientManager() {
    _startProcessing();
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