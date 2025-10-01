import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../model/CardGame.dart';

class HandUpdate implements ExecutableInClient {

  final List<CardGame> handCards;

  HandUpdate(this.handCards);

  HandUpdate.fromJson(Map<String, dynamic> json) :
        handCards = List<CardGame>.from(json['executable']['cards'] as List);


  @override
  void execute({required PageInterface page}) {
    page.handleHandUpdate(this);
  }

  @override
  Map<String, dynamic> toJson() {

    throw UnimplementedError();
  }

}