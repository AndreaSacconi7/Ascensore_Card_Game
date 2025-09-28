import 'package:flutter/material.dart';
import 'package:test_socket/components/TakenWidget.dart';
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
    return SizedBox(
      width: 200, // Adjust width as needed
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
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Player Avatar
          Container(
            width: 92,
            height: 95,
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