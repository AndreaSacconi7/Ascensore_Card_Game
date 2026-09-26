import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Seconds left until [deadline], rounded up; zero once it has passed.
int secondsLeft(DateTime deadline) {
  final millis = deadline.difference(DateTime.now()).inMilliseconds;
  return millis <= 0 ? 0 : (millis / 1000).ceil();
}

/// Share of the turn still left, from 1 to 0.
double turnFractionLeft(DateTime deadline, Duration length) {
  if (length <= Duration.zero) return 0;
  final left = deadline.difference(DateTime.now()).inMilliseconds / length.inMilliseconds;
  return left.clamp(0.0, 1.0);
}

/// The last seconds of a turn are shown in red.
const hurrySeconds = 10;

/// "23s", ticking down to [deadline]; red in the last seconds.
class CountdownText extends StatefulWidget {
  final DateTime deadline;
  final double fontSize;

  const CountdownText({super.key, required this.deadline, this.fontSize = 13});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late final Timer _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => setState(() {}));

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = secondsLeft(widget.deadline);
    final hurry = seconds <= hurrySeconds;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: widget.fontSize + 2, color: hurry ? AppColors.danger : AppColors.gold),
        const SizedBox(width: 3),
        Text(
          '${seconds}s',
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w800,
            color: hurry ? AppColors.danger : AppColors.gold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
