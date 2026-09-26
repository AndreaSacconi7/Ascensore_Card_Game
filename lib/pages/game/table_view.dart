import 'package:flutter/material.dart';

import '../../model/card_game.dart';
import '../../model/game.dart';
import '../../model/player.dart';
import '../../model/player_state.dart';
import '../../ui/game_widgets.dart';
import '../../ui/theme.dart';

/// The green felt with the current trick: your card at the bottom, opponents' cards around it.
/// Cards can be dropped on it to play them.
class TableView extends StatelessWidget {
  final Game game;
  final Player me;
  final List<Player> opponents;
  final bool Function(CardGame card) canDrop;
  final void Function(CardGame card) onDrop;

  const TableView({
    super.key,
    required this.game,
    required this.me,
    required this.opponents,
    required this.canDrop,
    required this.onDrop,
  });

  // Where each opponent's card sits, by number of opponents, in seating order (clockwise)
  static const _slots = {
    1: [Alignment(0, -0.78)],
    2: [Alignment(-0.72, -0.35), Alignment(0.72, -0.35)],
    3: [Alignment(-0.78, -0.05), Alignment(0, -0.78), Alignment(0.78, -0.05)],
  };

  @override
  Widget build(BuildContext context) {
    return DragTarget<CardGame>(
      onWillAcceptWithDetails: (details) => canDrop(details.data),
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth * 0.19).clamp(52.0, 92.0).toDouble();
            final fitsHeight = constraints.maxHeight * 0.34 * PlayingCard.aspectRatio;
            final width = cardWidth < fitsHeight ? cardWidth : fitsHeight;
            final slots = _slots[opponents.length] ?? _slots[3]!;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
                gradient: const RadialGradient(
                  colors: [AppColors.felt, AppColors.feltEdge],
                  radius: 0.9,
                ),
                border: Border.all(
                  color: hovering ? AppColors.gold : AppColors.gold.withValues(alpha: 0.25),
                  width: hovering ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 12)),
                  if (hovering) BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 30),
                ],
              ),
              child: Stack(
                children: [
                  Center(child: _BettingSummary(game: game)),
                  Positioned(top: 14, left: 16, child: _TrickCounter(game: game)),
                  for (var i = 0; i < opponents.length && i < slots.length; i++)
                    Align(alignment: slots[i], child: _Seat(player: opponents[i], game: game, width: width)),
                  Align(
                    alignment: const Alignment(0, 0.8),
                    child: _Seat(player: me, game: game, width: width, isMe: true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// One player's place on the table: their card of this trick, or an empty slot while they are to play.
class _Seat extends StatelessWidget {
  final Player player;
  final Game game;
  final double width;
  final bool isMe;

  const _Seat({required this.player, required this.game, required this.width, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final card = player.playedCard;
    final waitingForCard = card == null && player.playerState == PlayerState.PUT;
    final Widget content;
    if (card != null) {
      content = PlayingCard(
        key: ValueKey('${player.nickname}-$card'),
        card: card,
        width: width,
        highlighted: game.trickWinner == player.nickname,
      );
    } else if (waitingForCard) {
      content = EmptyCardSlot(key: ValueKey('${player.nickname}-empty'), width: width, icon: Icons.more_horiz_rounded);
    } else {
      content =
          SizedBox(key: ValueKey('${player.nickname}-none'), width: width, height: width / PlayingCard.aspectRatio);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: content,
        ),
        if (!isMe && (card != null || waitingForCard)) ...[
          const SizedBox(height: 6),
          Text(
            player.nickname,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

/// While players bet: how the total compares with the tricks on offer.
class _BettingSummary extends StatelessWidget {
  final Game game;

  const _BettingSummary({required this.game});

  @override
  Widget build(BuildContext context) {
    final betting = game.players.any((p) => p.playerState == PlayerState.BET);
    if (!betting) return const SizedBox.shrink();
    final totalBets = game.players.fold<int>(0, (sum, p) => sum + p.bet);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$totalBets / ${game.set}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w800, fontSize: 30),
        ),
        Text('scommesse / prese in palio', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
      ],
    );
  }
}

/// Which trick of the set is being played.
class _TrickCounter extends StatelessWidget {
  final Game game;

  const _TrickCounter({required this.game});

  @override
  Widget build(BuildContext context) {
    final playing = game.players.any((p) => p.playerState == PlayerState.PUT) || game.trickWinner != null;
    if (!playing) return const SizedBox.shrink();
    final trick = (game.trickWinner != null ? game.round : game.round + 1).clamp(1, game.set);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Presa $trick/${game.set}',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
