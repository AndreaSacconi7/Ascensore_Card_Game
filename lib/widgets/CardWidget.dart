import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String cardName;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.cardName,
    this.width = 92,
    this.height = 95,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/cards/yoga.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}