import 'dart:convert';

import 'package:test_socket/command/CommandType.dart';
import 'package:test_socket/command/ExecutableInServer.dart';

class Command {
  final CommandType commandType;
  ExecutableInServer? executable;
  String? nickName;

  Command({
    required this.commandType,
    this.executable,
    this.nickName,
  });

  // Metodo per serializzare in JSON
  String toJson() {
    return jsonEncode({
      'commandType': commandType.toString().split('.').last,
      'executable': executable?.toJson(),
      'clientSessionId': nickName,
    });
  }
}