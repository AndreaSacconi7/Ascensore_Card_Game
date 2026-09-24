import 'package:flutter/material.dart';

import '../model/card_game.dart';
import '../model/seed.dart';

class PlayedCardWidget extends StatelessWidget {
  final ValueNotifier<CardGame?> playedCardNotifier;
  final double width;
  final double height;

  const PlayedCardWidget({
    super.key,
    required this.playedCardNotifier,
    this.width = 51,
    this.height = 85,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CardGame?>(
      valueListenable: playedCardNotifier,
      builder: (context, playedCard, child) {
        debugPrint('PlayedCardWidget rebuild: ${playedCard?.seed ?? "null"}');
        if (playedCard == null || playedCard.getSeed() == Seed.VOID) {
          return SizedBox(
            width: width,
            height: height,
          );
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(playedCard.getImagePath()),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}