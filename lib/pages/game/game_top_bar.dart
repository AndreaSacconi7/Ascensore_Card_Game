import 'package:flutter/material.dart';

import '../../model/game.dart';
import '../../ui/game_widgets.dart';
import '../../ui/theme.dart';
import '../rules_sheet.dart';

/// Where the match is (elevator floor), the briscola, and the rules.
class GameTopBar extends StatelessWidget {
  final Game game;

  const GameTopBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final briscola = game.briscola;
    return Row(
      children: [
        FloorIndicator(
          handSize: game.set,
          setNumber: game.setNumber,
          totalSets: game.totalSets,
          goingUp: game.goingUp,
          peak: game.isPeakSet,
        ),
        const Spacer(),
        Tooltip(
          message: briscola == null && game.isPeakSet
              ? 'Mano da ${game.maxHandSize}: la briscola è il seme della prima carta di ogni presa'
              : 'Briscola',
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('BRISCOLA',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.4)),
                  Text(
                    briscola == null ? (game.isPeakSet ? '1ª carta' : '–') : _seedName(briscola.seed.name),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              briscola == null
                  ? const EmptyCardSlot(width: 34, icon: Icons.question_mark_rounded)
                  : PlayingCard(card: briscola, width: 34, highlighted: true),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Come si gioca',
          onPressed: () => showRulesSheet(context),
          icon: const Icon(Icons.help_outline_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  static String _seedName(String seed) => switch (seed) {
        'COINS' => 'Denari',
        'CUPS' => 'Coppe',
        'SWORDS' => 'Spade',
        'STICKS' => 'Bastoni',
        _ => seed,
      };
}
