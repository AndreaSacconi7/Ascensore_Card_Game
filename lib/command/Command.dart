import 'package:test_socket/command/CommandType.dart';
import 'package:test_socket/command/ExecutableInServer.dart';

class Command {
  final CommandType type;
  ExecutableInServer? executable;
  String? clientSessionId;

  Command({
    required this.type,
    this.executable,
    this.clientSessionId,
  });

  // Metodo per serializzare in JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'executable': executable?.toJson(),
      'clientSessionId': clientSessionId,
    };
  }
}