import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import 'MessageType.dart';

class Message {
  final ExecutableInClient executable;
  final String nickName;
  //si riconosce il tipo di messaggio nel clientManager con gli if in cascata
  final MessageType messageType;

  Message({
    required this.executable,
    required this.nickName,
    required this.messageType,
  });

  // Convert from JSON
  factory Message.fromJson(Map<String, dynamic> json, ExecutableInClient executable) {
    return Message(
      //executable già pronto
      executable: executable,
      nickName: json['nickname'],
      messageType: MessageType.values.firstWhere((e) => e.toString().split('.').last == json['messageType'], orElse: () => throw ArgumentError('Invalid messageType: ${json['messageType']}'),)
    );
  }

  /*
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'executable': executable.toJson(),
      'nickName': nickName,
    };
  }*/

  Future<void> execute(PageInterface page) async {
    executable.execute(page: page);
  }
}
