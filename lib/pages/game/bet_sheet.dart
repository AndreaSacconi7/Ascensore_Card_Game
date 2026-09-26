import 'package:flutter/material.dart';

import '../../model/game.dart';
import '../../model/game_rules.dart';
import '../../model/player.dart';
import '../../ui/components.dart';
import '../../ui/game_widgets.dart';
import '../../ui/theme.dart';

/// Asks how many tricks you will take. Returns the bet, or null if the sheet was closed for you
/// (the turn moved on).
Future<int?> showBetSheet(BuildContext context, {required Game game, required Player me}) {
  return showModalBottomSheet<int>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) => _BetSheet(game: game, me: me),
  );
}

class _BetSheet extends StatefulWidget {
  final Game game;
  final Player me;

  const _BetSheet({required this.game, required this.me});

  @override
  State<_BetSheet> createState() => _BetSheetState();
}

class _BetSheetState extends State<_BetSheet> {
  int? _bet;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final handSize = game.set;
    final forbidden = GameRules.forbiddenBet(
      playerOrder: game.playerOrder,
      myNickname: widget.me.nickname,
      cardsInHand: handSize,
    );
    final others = game.playerOrder.where((p) => p != widget.me).toList();
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La tua scommessa', style: textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Quante prese farai con ${handSize == 1 ? '1 carta' : '$handSize carte'}?',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (game.briscola != null) PlayingCard(card: game.briscola!, width: 40, highlighted: true),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in others)
                  StatChip(
                    icon: Icons.flag_rounded,
                    value: '${p.nickname}: ${p.hasBet ? p.bet : '…'}',
                    color: p.hasBet ? AppColors.textSecondary : AppColors.textMuted,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var value = 0; value <= handSize; value++)
                  _BetOption(
                    value: value,
                    selected: _bet == value,
                    forbidden: value == forbidden,
                    onTap: () => setState(() => _bet = value),
                  ),
              ],
            ),
            if (forbidden != null) ...[
              const SizedBox(height: 14),
              Text(
                'Sei l\'ultimo: non puoi dire $forbidden, il totale sarebbe uguale alle carte in mano.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            AppButton(
              label: _bet == null ? 'SCEGLI UN NUMERO' : 'SCOMMETTO $_bet',
              onPressed: _bet == null ? null : () => Navigator.of(context).pop(_bet),
            ),
          ],
        ),
      ),
    );
  }
}

class _BetOption extends StatelessWidget {
  final int value;
  final bool selected;
  final bool forbidden;
  final VoidCallback onTap;

  const _BetOption({required this.value, required this.selected, required this.forbidden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: forbidden ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldGradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: selected ? Colors.transparent : AppColors.border),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.onGold : (forbidden ? AppColors.textMuted : AppColors.textPrimary),
              decoration: forbidden ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.danger,
              decorationThickness: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}
