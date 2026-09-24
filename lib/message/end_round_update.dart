
import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';

class EndRoundUpdate implements ExecutableInClient {

  final Map<String, int> nextPlayerOrderAndTaken;
  final int nextRoundNumber;

  EndRoundUpdate.fromJson(Map<String, dynamic> json) :
        nextPlayerOrderAndTaken = (json['executable']['nextPlayerOrderAndTaken']
          as Map<String, dynamic>).map((key, value) => MapEntry(
            key,
            value as int,
        )),
        nextRoundNumber = json['executable']['nextRoundNumber'] as int;

  @override
  void execute({required ClientManager clientManager}) {

    clientManager.handleEndRoundUpdate(this);
  }


}