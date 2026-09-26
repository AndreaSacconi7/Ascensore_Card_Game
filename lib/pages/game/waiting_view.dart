import 'package:flutter/material.dart';

import '../../ui/game_widgets.dart';

/// Matchmaking: an elevator going up and down while the server looks for opponents.
class WaitingView extends StatefulWidget {
  const WaitingView({super.key});

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> with SingleTickerProviderStateMixin {
  late final AnimationController _ride = AnimationController(vsync: this, duration: const Duration(seconds: 7))
    ..repeat();

  @override
  void dispose() {
    _ride.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ride,
              builder: (context, _) {
                // One ride: floors 1..10 and back down, like a match
                final step = (_ride.value * 19).floor().clamp(0, 18);
                final floor = step < 10 ? step + 1 : 19 - step;
                return FloorIndicator(
                  handSize: floor,
                  setNumber: step + 1,
                  totalSets: 19,
                  goingUp: step < 9,
                  peak: step == 9,
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Cerco un avversario…', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'La partita inizia appena si unisce un altro giocatore.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            const SizedBox(width: 160, child: LinearProgressIndicator(minHeight: 3)),
          ],
        ),
      ),
    );
  }
}
