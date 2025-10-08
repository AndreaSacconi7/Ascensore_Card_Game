import '../pages/PageInterface.dart';
import 'ExecutableInClient.dart';

class TextMessage implements ExecutableInClient {

  final String text;

  TextMessage(this.text);

  @override
  void execute({required PageInterface page}) {
    page.handleTextMessage(this);
  }
}