import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/card_game.dart';
import '../../ui/game_widgets.dart';
import '../../ui/theme.dart';

/// Your hand as a fan. On your turn, tap a card to lift it and tap again to play it, or drag it onto
/// the table; cards you may not play (you must follow the lead seed) are dimmed.
class HandFan extends StatefulWidget {
  final List<CardGame> cards;
  final bool canPlay;
  final bool Function(CardGame card) isPlayable;
  final void Function(CardGame card) onPlay;
  final void Function(CardGame card) onBlocked;

  const HandFan({
    super.key,
    required this.cards,
    required this.canPlay,
    required this.isPlayable,
    required this.onPlay,
    required this.onBlocked,
  });

  @override
  State<HandFan> createState() => _HandFanState();
}

class _HandFanState extends State<HandFan> {
  CardGame? _selected;

  @override
  void didUpdateWidget(HandFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.canPlay || !widget.cards.contains(_selected)) {
      _selected = null;
    }
  }

  void _tap(CardGame card) {
    if (!widget.canPlay) return;
    if (!widget.isPlayable(card)) {
      widget.onBlocked(card);
      return;
    }
    if (_selected == card) {
      widget.onPlay(card);
      setState(() => _selected = null);
    } else {
      setState(() => _selected = card);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final n = cards.length;
        final cardWidth = min(86.0, maxWidth / max(4.2, n * 0.62 + 0.6));
        final cardHeight = cardWidth / PlayingCard.aspectRatio;
        final step = n <= 1 ? 0.0 : min(cardWidth * 0.78, (maxWidth - cardWidth - 16) / (n - 1));
        final total = cardWidth + step * max(0, n - 1);
        final left0 = (maxWidth - total) / 2;
        final middle = (n - 1) / 2;
        final maxAngle = min(0.08, 0.45 / max(1, n));

        return SizedBox(
          height: cardHeight + 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < n; i++)
                _positioned(
                  card: cards[i],
                  left: left0 + i * step,
                  // Cards away from the middle sit lower, like a fan held in hand
                  bottom: 22 - pow((i - middle) / max(middle, 1), 2) * 12 + (_selected == cards[i] ? 22 : 0),
                  angle: (i - middle) * maxAngle,
                  width: cardWidth,
                ),
              if (_selected != null)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Tocca di nuovo per giocarla',
                      style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _positioned({
    required CardGame card,
    required double left,
    required double bottom,
    required double angle,
    required double width,
  }) {
    final playable = !widget.canPlay || widget.isPlayable(card);
    final visual = PlayingCard(
      card: card,
      width: width,
      highlighted: _selected == card,
      dimmed: !playable,
    );
    return AnimatedPositioned(
      key: ValueKey(card),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      left: left,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => _tap(card),
          child: Draggable<CardGame>(
            data: card,
            maxSimultaneousDrags: widget.canPlay && playable ? 1 : 0,
            feedback: Material(
              color: Colors.transparent,
              child:
                  Transform.rotate(angle: 0.05, child: PlayingCard(card: card, width: width * 1.1, highlighted: true)),
            ),
            childWhenDragging: Opacity(opacity: 0.25, child: visual),
            child: MouseRegion(
                cursor: widget.canPlay && playable ? SystemMouseCursors.click : MouseCursor.defer, child: visual),
          ),
        ),
      ),
    );
  }
}
