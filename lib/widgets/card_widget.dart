import 'package:flutter/material.dart';

import '../model/card_game.dart';

class CardWidget extends StatelessWidget {
  final CardGame card;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 51,
    this.height = 85,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(card.getImagePath()),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}