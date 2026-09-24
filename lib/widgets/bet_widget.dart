import 'package:flutter/material.dart';

class BetWidget extends StatelessWidget {
  final ValueNotifier<int> betNotifier;

  const BetWidget({super.key, required this.betNotifier});

  @override
  Widget build(BuildContext context) {
    // Dimensione fissa, indipendente dallo schermo
    const double buttonSize = 50.0;
    const double buttonHeight = buttonSize;

    return ValueListenableBuilder<int>(
      valueListenable: betNotifier,
      builder: (context, betValue, child) {
        return Container(
          width: buttonSize, // Usa la larghezza fissa
          height: buttonHeight, // Usa l'altezza fissa
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF2B2E4A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                betValue.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}