import 'package:flutter/material.dart';

class BetWidget extends StatelessWidget {
  final ValueNotifier<int> betNotifier;

  const BetWidget({super.key, required this.betNotifier});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final playerWidgetWidth = screenWidth * 0.3; // 30% of screen width
    final buttonSize = playerWidgetWidth * 0.4; // 40% of widget width
    final buttonHeight = buttonSize;

    return ValueListenableBuilder<int>(
      valueListenable: betNotifier,
      builder: (context, betValue, child) {
        return Container(
          width: buttonSize,
          height: buttonHeight,
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
                  fontSize: 10,
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