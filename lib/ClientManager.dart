import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/message/Message.dart';
import 'package:test_socket/message/MessageType.dart';
import 'package:test_socket/pages/PageInterface.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'command/Command.dart';


class ClientManager {
  final Queue<Message> _messageQueue = Queue<Message>();
  final _condition = Condition();
  bool _isRunning = false;
  late final WebSocketChannel channel;
  late final Stream _stream;
  PageInterface? currentPage;
  String? nickName;

  ClientManager(WebSocketChannel channel) {
    this.channel = channel;
    _stream = channel.stream.asBroadcastStream();
    _stream.listen(_handleMessage);
    _startProcessing();
  }

  void setCurrentPage(PageInterface page) {
    currentPage = page;
  }

  PageInterface? getCurrentPage() {
    return currentPage;
  }

  void setNickname(String nickName) {
    this.nickName = nickName;
  }

  String? getNickname() {
    return nickName;
  }

  void sendCommand(dynamic jsonCommand){
    print('Sending command to server: $jsonCommand');
    channel.sink.add(jsonCommand);
  }

  void _handleMessage(dynamic jsonMessage) {
    // Gestisci i messaggi in arrivo dal server WebSocket
    print('Message from server: $jsonMessage');

    // Parsing della stringa JSON in una mappa
    final Map<String, dynamic> jsonMap = jsonDecode(jsonMessage);

    final message;

    final String stringMessageType = jsonMap['messageType'];

    if(stringMessageType == 'LOGIN_RESPONSE'){
      final executable = LoginResponse.fromJson(jsonMap);
      message = Message.fromJson(jsonMap, executable);
    } else {
      print('Unknown message type: ${jsonMap['messageType']}');
      return;
    }

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
        message?.execute(currentPage!);
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