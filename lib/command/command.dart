import 'dart:convert';

import 'package:ascensore_client/command/command_type.dart';
import 'package:ascensore_client/command/executable_in_server.dart';

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