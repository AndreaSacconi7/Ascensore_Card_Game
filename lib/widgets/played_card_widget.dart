import 'package:flutter/material.dart';

import '../model/card_game.dart';

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
        if (playedCard == null) {
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
              image: AssetImage(playedCard.imagePath),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}