import '../pages/PageInterface.dart';
import 'ExecutableInClient.dart';

class EndSetUpdate implements ExecutableInClient {

  final Map<String, int> nextPlayerOrderAndScore;
  final int nextSetNumber;

  EndSetUpdate.fromJson(Map<String, dynamic> json) :
        nextPlayerOrderAndScore = (json['executable']['nextPlayerOrderAndScore']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key as String,
          value as int,
        )),
        nextSetNumber = json['executable']['nextSetNumber'] as int;

  @override
  void execute({required PageInterface page}) {

    page.handleEndSetUpdate(this);
  }
}