
import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';
import 'message_type.dart';

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

  Future<void> execute(ClientManager clientManager) async {
    executable.execute(clientManager: clientManager);
  }
}
