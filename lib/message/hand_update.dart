import '../client_manager.dart';
import '../model/card_game.dart';
import 'executable_in_client.dart';

class HandUpdate implements ExecutableInClient {
  final List<CardGame> handCards;

  HandUpdate.fromJson(Map<String, dynamic> json)
      : handCards = (json['cards'] as List).map((card) => CardGame.fromJson(card as Map<String, dynamic>)).toList();

  @override
  void execute({required ClientManager clientManager}) => clientManager.handleHandUpdate(this);
}
