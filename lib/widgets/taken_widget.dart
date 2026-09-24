import 'package:flutter/material.dart';

class TakenWidget extends StatefulWidget {
  final ValueNotifier<int> roundsWonNotifier;

  const TakenWidget({Key? key, required this.roundsWonNotifier}) : super(key: key);

  @override
  _TakenWidgetState createState() => _TakenWidgetState();
}

class _TakenWidgetState extends State<TakenWidget> {
  @override
  Widget build(BuildContext context) {

    final double buttonSize = 50.0;
    final double buttonHeight = buttonSize;

    return ValueListenableBuilder<int>(
      valueListenable: widget.roundsWonNotifier,
      builder: (context, roundsWon, child) {
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
                roundsWon.toString(),
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