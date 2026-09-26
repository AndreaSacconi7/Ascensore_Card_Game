import 'package:flutter/material.dart';

import '../model/card_game.dart';
import '../model/seed.dart';
import 'theme.dart';

/// Round avatar with the player's initials. [active] adds a pulsing gold ring: it is their turn.
class PlayerAvatar extends StatefulWidget {
  final String nickname;
  final double size;
  final bool active;
  final bool faded;

  const PlayerAvatar({
    super.key,
    required this.nickname,
    this.size = 48,
    this.active = false,
    this.faded = false,
  });

  static const _gradients = [
    [Color(0xFF7C8CFF), Color(0xFF4B52D6)],
    [Color(0xFFFF8A9A), Color(0xFFD9466B)],
    [Color(0xFF5EE6C2), Color(0xFF179C7C)],
    [Color(0xFFFFC46B), Color(0xFFE0842B)],
    [Color(0xFFB98CFF), Color(0xFF7447D6)],
    [Color(0xFF6CCBFF), Color(0xFF237BC9)],
  ];

  @override
  State<PlayerAvatar> createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    if (widget.active) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PlayerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = PlayerAvatar._gradients[widget.nickname.hashCode.abs() % PlayerAvatar._gradients.length];
    final initials = widget.nickname.isEmpty ? '?' : widget.nickname.substring(0, 1).toUpperCase();

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = widget.active ? 6 + 10 * _pulse.value : 0.0;
        return Container(
          width: widget.size + 8,
          height: widget.size + 8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.active ? AppColors.gold : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (widget.active) BoxShadow(color: AppColors.gold.withValues(alpha: 0.45), blurRadius: glow),
            ],
          ),
          child: child,
        );
      },
      child: Opacity(
        opacity: widget.faded ? 0.4 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: widget.size * 0.42,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A card of the Italian deck with rounded corners and a soft shadow.
class PlayingCard extends StatelessWidget {
  static const aspectRatio = 177 / 285;

  final CardGame card;
  final double width;
  final bool highlighted;
  final bool dimmed;

  const PlayingCard({
    super.key,
    required this.card,
    this.width = 64,
    this.highlighted = false,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(width * 0.1);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      height: width / aspectRatio,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: highlighted ? AppColors.gold : Colors.black.withValues(alpha: 0.08),
          width: highlighted ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
          if (highlighted) BoxShadow(color: AppColors.gold.withValues(alpha: 0.6), blurRadius: 18),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Image.asset(card.imagePath, fit: BoxFit.contain, semanticLabel: card.toString()),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              color: Colors.black.withValues(alpha: dimmed ? 0.5 : 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where a card will go: an outlined slot, optionally with a hint inside.
class EmptyCardSlot extends StatelessWidget {
  final double width;
  final String? label;
  final IconData? icon;

  const EmptyCardSlot({super.key, this.width = 64, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width / PlayingCard.aspectRatio,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.4),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: width * 0.3),
            if (label != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, height: 1.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Elevator floor display: the hand size of the current set with the direction of travel,
/// and where the set sits in the match.
class FloorIndicator extends StatelessWidget {
  final int handSize;
  final int setNumber;
  final int totalSets;
  final bool goingUp;
  final bool peak;

  const FloorIndicator({
    super.key,
    required this.handSize,
    required this.setNumber,
    required this.totalSets,
    required this.goingUp,
    required this.peak,
  });

  @override
  Widget build(BuildContext context) {
    final arrow =
        peak ? Icons.unfold_more_rounded : (goingUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded);
    return Tooltip(
      message: 'Mano $setNumber di $totalSets: $handSize ${handSize == 1 ? 'carta' : 'carte'} a testa',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
        decoration: BoxDecoration(
          color: const Color(0xFF070A1A),
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.12), blurRadius: 16)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(arrow, color: AppColors.gold, size: 28),
            Text(
              '$handSize',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
                shadows: [Shadow(color: AppColors.goldDeep, blurRadius: 12)],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('MANO', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.4)),
                Text(
                  '$setNumber/$totalSets',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Three fanned cards, as an illustration on the entry screens.
class DecorativeCardFan extends StatelessWidget {
  final double cardWidth;

  const DecorativeCardFan({super.key, this.cardWidth = 70});

  static const _cards = [
    CardGame(Seed.CUPS, 1),
    CardGame(Seed.COINS, 3),
    CardGame(Seed.SWORDS, 10),
  ];

  @override
  Widget build(BuildContext context) {
    final height = cardWidth / PlayingCard.aspectRatio;
    return SizedBox(
      width: cardWidth * 2.6,
      height: height * 1.12,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          for (var i = 0; i < _cards.length; i++)
            Transform.translate(
              offset: Offset((i - 1) * cardWidth * 0.62, (i == 1 ? -height * 0.06 : 0)),
              child: Transform.rotate(
                angle: (i - 1) * 0.22,
                alignment: Alignment.bottomCenter,
                child: PlayingCard(card: _cards[i], width: cardWidth),
              ),
            ),
        ],
      ),
    );
  }
}
