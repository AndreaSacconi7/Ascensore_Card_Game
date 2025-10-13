import '../pages/PageInterface.dart';
import 'ExecutableInClient.dart';

class TextMessage implements ExecutableInClient {

  final String text;

  TextMessage(this.text);

  TextMessage.fromJson(Map<String, dynamic> json) :
        text = json['executable']['text'] as String;


  @override
  void execute({required PageInterface page}) {
    page.handleTextMessage(this);
  }
}