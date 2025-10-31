import 'package:flutter/material.dart';
import 'package:test_socket/widgets/ScoreWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import '../model/Player.dart';
import 'BetWidget.dart';

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
    // Get screen width and height
    // NON ABBIAMO PIÙ BISOGNO DI MEDIASCREEN
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // --- SOLUZIONE ---
    // Imposta una larghezza fissa invece di una percentuale.
    // 120.0 è un esempio, modificalo finché non trovi la dimensione
    // che preferisci e che corrisponde a quella mobile.
    final double widgetWidth = 120.0;
    // --- FINE SOLUZIONE ---

    // Questo calcolo ora userà la larghezza fissa (120.0 * 0.4)
    final avatarSize = widgetWidth * 0.4;

    return SizedBox(
      width: widgetWidth, // Usa la larghezza fissa
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player Name
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
          // Player Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cards/yoga.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 15),
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