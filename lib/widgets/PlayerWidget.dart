import 'package:flutter/material.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import 'BetWidget.dart';

class PlayerWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const PlayerWidget({
    Key? key,
    required this.name,
    required this.avatarUrl,
  }) : super(key: key);

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
          // Player Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontFamily: 'Late',
              fontWeight: FontWeight.w100,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          // Two Bet Widgets
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TakenWidget(),
              BetWidget(),
            ],
          ),
        ],
      ),
    );
  }
}