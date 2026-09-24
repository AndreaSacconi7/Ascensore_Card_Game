import 'package:flutter/material.dart';

import '../model/CardGame.dart';
import '../model/Seed.dart';

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
        print('PlayedCardWidget rebuild: ${playedCard?.seed ?? "null"}');
        if (playedCard == null || playedCard.getSeed() == Seed.VOID) {
          return SizedBox(
            width: width,
            height: height,
            /*decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No Card',
                style: TextStyle(color: Colors.white),
              ),
            ),*/
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