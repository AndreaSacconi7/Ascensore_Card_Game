import 'package:flutter/material.dart';

import '../model/CardGame.dart';

class CardWidget extends StatelessWidget {
  final CardGame card;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 92,
    this.height = 95,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(card.getImagePath()),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}