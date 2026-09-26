import 'package:flutter/material.dart';
import 'package:ascensore_client/widgets/score_widget.dart';
import 'package:ascensore_client/widgets/taken_widget.dart';
import '../model/player.dart';
import 'bet_widget.dart';

class PlayerWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final Player player;

  const PlayerWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.player
  });

  @override
  Widget build(BuildContext context) {
    const double widgetWidth = 120.0;
    const avatarSize = widgetWidth * 0.4;

    return SizedBox(
      width: widgetWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Late',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: avatarSize * 0.7),
          ),
          const SizedBox(height: 15),
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