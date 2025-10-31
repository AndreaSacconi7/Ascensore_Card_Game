import 'package:test_socket/message/ExecutableInClient.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../ClientManager.dart';
import '../model/CardGame.dart';

class BriscolaUpdate implements ExecutableInClient {

  final CardGame briscolaCard;

  BriscolaUpdate(this.briscolaCard);

  factory BriscolaUpdate.fromJson(Map<String, dynamic> json){

    final briscolaCard = CardGame.fromJson(json['executable']['briscolaCard']);

    return BriscolaUpdate(briscolaCard);
  }


  @override
  void execute({required ClientManager clientManager}) {
    clientManager.handleBriscolaUpdate(this);
  }




}
