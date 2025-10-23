import 'package:flutter/material.dart';
import 'package:test_socket/widgets/ScoreWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import '../model/Player.dart';
import 'BetWidget.dart';

class MySelfBetTakenScoreWidget extends StatelessWidget {
  final Player player;

  const MySelfBetTakenScoreWidget({
    super.key,
    required this.player
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic dimensions
    final widgetWidth = screenWidth * 0.3; // 30% of screen width
    final avatarSize = widgetWidth * 0.4; // 40% of widget width

    return SizedBox(
      width: widgetWidth,
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