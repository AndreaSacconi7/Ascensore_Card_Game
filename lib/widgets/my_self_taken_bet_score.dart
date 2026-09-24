import 'package:flutter/material.dart';
import 'package:test_socket/widgets/ScoreWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import '../model/Player.dart';
import 'package:test_socket/widgets/BetWidget.dart';

class MySelfBetTakenScoreWidget extends StatelessWidget {
  final Player player;

  const MySelfBetTakenScoreWidget({
    super.key,
    required this.player
  });

  @override
  Widget build(BuildContext context) {
    // Rimuoviamo la larghezza dello schermo, non ci serve
    // final screenWidth = MediaQuery.of(context).size.width;

    // --- SOLUZIONE ---
    // Imposta una larghezza fissa.
    // 140.0 è un esempio, modificalo tu per trovare la
    // dimensione "giusta" che avevi su mobile.
    final double widgetWidth = 140.0;
    // --- FINE SOLUZIONE ---

    return SizedBox(
      width: widgetWidth, // Usa la larghezza fissa
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score Widget
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScoreWidget(scoreNotifier: player.scoreNotifier),
              ]
          ),
          const SizedBox(height: 15),
          // Two Bet Widgets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BetWidget(betNotifier: player.betNotifier),
              TakenWidget(roundsWonNotifier: player.roundsWonNotifier),
            ],
          ),
        ],
      ),
    );
  }
}