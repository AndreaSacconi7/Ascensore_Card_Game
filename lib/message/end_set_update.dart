import '../client_manager.dart';
import 'executable_in_client.dart';

class EndSetUpdate implements ExecutableInClient {

  final Map<String, int> nextPlayerOrderAndScore;
  final int nextSetNumber;

  EndSetUpdate.fromJson(Map<String, dynamic> json) :
        nextPlayerOrderAndScore = (json['executable']['nextPlayerOrderAndScore']
        as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          value as int,
        )),
        nextSetNumber = json['executable']['nextSetNumber'] as int;

  @override
  void execute({required ClientManager clientManager}) {

    clientManager.handleEndSetUpdate(this);
  }
}