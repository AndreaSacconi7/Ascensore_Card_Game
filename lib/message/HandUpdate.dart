import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../model/CardGame.dart';

class HandUpdate implements ExecutableInClient {

  final List<CardGame> handCards;

  HandUpdate(this.handCards);

  HandUpdate.fromJson(Map<String, dynamic> json) :
        handCards = (json['executable']['cards'] as List)
            .map((cardJson) => CardGame.fromJson(cardJson as Map<String, dynamic>))
            .toList();

  @override
  void execute({required PageInterface page}) {
    page.handleHandUpdate(this);
  }



}