import 'dart:collection';

import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../ClientManager.dart';

class EndRoundUpdate implements ExecutableInClient {

  final Map<String, int> nextPlayerOrderAndTaken;
  final int nextRoundNumber;

  EndRoundUpdate.fromJson(Map<String, dynamic> json) :
        nextPlayerOrderAndTaken = (json['executable']['nextPlayerOrderAndTaken']
          as Map<String, dynamic>).map((key, value) => MapEntry(
            key as String,
            value as int,
        )),
        nextRoundNumber = json['executable']['nextRoundNumber'] as int;

  @override
  void execute({required ClientManager clientManager}) {

    clientManager.handleEndRoundUpdate(this);
  }


}