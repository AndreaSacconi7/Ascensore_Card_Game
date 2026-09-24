import '../ClientManager.dart';
import '../pages/PageInterface.dart';
import 'ExecutableInClient.dart';

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