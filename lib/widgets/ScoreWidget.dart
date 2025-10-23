import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget{
  final ValueNotifier<int> scoreNotifier;

  const ScoreWidget({super.key, required this.scoreNotifier});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<int>(
        valueListenable: scoreNotifier,
        builder: (context, scoreValue, child) {
          return Row(
            children: [
              Text(
                  "$scoreValue pt",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )
              )
            ],
          );
        }
    );
  }

}