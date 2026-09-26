import 'package:flutter/material.dart';

import '../../model/player.dart';
import '../../model/player_state.dart';
import '../../ui/components.dart';
import '../../ui/game_widgets.dart';
import '../../ui/theme.dart';

/// An opponent: avatar (glowing on their turn), name, score, bet and tricks taken.
class OpponentTile extends StatelessWidget {
  final Player player;

  const OpponentTile({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final state = player.playerState;
    final left = state == PlayerState.EXIT;
    final status = switch (state) {
      PlayerState.BET => 'scommette…',
      PlayerState.PUT => 'gioca…',
      PlayerState.EXIT => 'ha lasciato',
      _ => null,
    };

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
      radius: AppRadius.medium,
      borderColor: status != null && !left ? AppColors.gold.withValues(alpha: 0.6) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerAvatar(
            nickname: player.nickname,
            size: 34,
            active: state == PlayerState.BET || state == PlayerState.PUT,
            faded: left,
          ),
          const SizedBox(height: 6),
          Text(
            player.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          SizedBox(
            height: 15,
            child: status == null
                ? null
                : Text(status, style: TextStyle(fontSize: 11, color: left ? AppColors.danger : AppColors.gold)),
          ),
          const SizedBox(height: 2),
          PlayerStats(player: player, compact: true),
        ],
      ),
    );
  }
}

/// Score, bet and tricks taken, kept live by the player's notifiers.
class PlayerStats extends StatelessWidget {
  final Player player;
  final bool compact;

  const PlayerStats({super.key, required this.player, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([player.scoreNotifier, player.betNotifier, player.roundsWonNotifier]),
      builder: (context, _) {
        final bet = player.hasBet ? '${player.bet}' : '–';
        final onTarget = player.hasBet && player.roundsWon == player.bet;
        final over = player.hasBet && player.roundsWon > player.bet;
        final tricksColor = over ? AppColors.danger : (onTarget ? AppColors.success : AppColors.textSecondary);
        if (compact) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InlineStat(icon: Icons.star_rounded, value: '${player.score}', color: AppColors.gold),
              const SizedBox(width: 10),
              _InlineStat(icon: Icons.style_rounded, value: '${player.roundsWon}/$bet', color: tricksColor),
            ],
          );
        }
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            StatChip(icon: Icons.star_rounded, value: '${player.score}', color: AppColors.gold, tooltip: 'Punti'),
            StatChip(
              icon: Icons.style_rounded,
              value: '${player.roundsWon}/$bet',
              color: tricksColor,
              tooltip: 'Prese / scommessa',
            ),
          ],
        );
      },
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InlineStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
