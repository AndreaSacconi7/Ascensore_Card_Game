import '../client_manager.dart';
import 'executable_in_client.dart';

class TextMessage implements ExecutableInClient {

  final String text;

  TextMessage(this.text);

  TextMessage.fromJson(Map<String, dynamic> json) :
        text = json['executable']['text'] as String;


  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleTextMessage(this);
  }
}