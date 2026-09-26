import 'package:flutter/material.dart';
import 'package:ascensore_client/widgets/score_widget.dart';
import 'package:ascensore_client/widgets/taken_widget.dart';
import '../model/player.dart';
import 'package:ascensore_client/widgets/bet_widget.dart';

class MySelfBetTakenScoreWidget extends StatelessWidget {
  final Player player;

  const MySelfBetTakenScoreWidget({
    super.key,
    required this.player
  });

  @override
  Widget build(BuildContext context) {
    const double widgetWidth = 140.0;

    return SizedBox(
      width: widgetWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScoreWidget(scoreNotifier: player.scoreNotifier),
              ]
          ),
          const SizedBox(height: 15),
          // Bet and tricks taken
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