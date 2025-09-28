import 'dart:convert';

import 'package:test_socket/message/ExecutableInClient.dart';

class Message {
  final ExecutableInClient executable;
  final String nickName;

  Message({
    required this.executable,
    required this.nickName,
  });

  // Convert from JSON
  factory Message.fromJson(Map<String, dynamic> json, ExecutableInClient Function(Map<String, dynamic>) executableFromJson) {
    return Message(
      executable: executableFromJson(json['executable']),
      nickName: json['nickName'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'executable': executable.toJson(),
      'nickName': nickName,
    };
  }

  void execute() {
    executable.execute();
  }
}
