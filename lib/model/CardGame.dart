import 'package:test_socket/model/Seed.dart';

class CardGame {

  final Seed seed;
  final int value;

  CardGame(this.seed, this.value);

  CardGame.fromJson(Map<String, dynamic> json) :
        seed = Seed.values.firstWhere((e) => e.toString() == 'Seed.' + json['seed']),
        value = json['value'] as int;

  Seed getSeed() {
    return seed;
  }

  int getValue() {
    return value;
  }

  //otterrò il path all'immagine della carta tramite seed e value (es: "assets/cards/SWORDS_4.png")
  String getImagePath() {
    return 'assets/cards/${seed.toString().split('.').last}_$value.png';
  }

}