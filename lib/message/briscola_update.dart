import 'package:ascensore_client/message/executable_in_client.dart';

import '../client_manager.dart';
import '../model/card_game.dart';

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
