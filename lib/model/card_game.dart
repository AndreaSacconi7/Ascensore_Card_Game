import 'package:ascensore_client/model/seed.dart';

/// A card of the 40-card Italian deck: value 1 is the ace, 8-10 are jack, knight and king.
class CardGame {
  final Seed seed;
  final int value;

  const CardGame(this.seed, this.value);

  CardGame.fromJson(Map<String, dynamic> json)
      : seed = Seed.values.byName(json['seed'] as String),
        value = json['value'] as int;

  /// Asset for this card, e.g. "assets/cards/SWORDS_4.png".
  String get imagePath => 'assets/cards/${seed.name}_$value.png';

  @override
  bool operator ==(Object other) => other is CardGame && other.seed == seed && other.value == value;

  @override
  int get hashCode => Object.hash(seed, value);

  @override
  String toString() => '${seed.name}_$value';
}
