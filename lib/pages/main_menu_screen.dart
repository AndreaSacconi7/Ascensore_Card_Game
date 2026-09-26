import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../ui/components.dart';
import '../ui/game_widgets.dart';
import '../ui/theme.dart';
import 'rules_sheet.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late int _players = context.read<ClientManager>().matchSize;

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ClientManager>();
    final nickname = context.select<ClientManager, String>((m) => m.mySelfPlayer?.nickname ?? '');
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ContentWidth(
        maxWidth: 480,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PlayerAvatar(nickname: nickname, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ciao,', style: textTheme.bodyMedium),
                        Text(nickname, style: textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Esci',
                    onPressed: manager.logOut,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              const Center(child: DecorativeCardFan(cardWidth: 76)),
              const SizedBox(height: 24),
              const Center(child: AppLogo(height: 44)),
              const SizedBox(height: 8),
              Text(
                'Scommetti le tue prese, mano dopo mano,\nsalendo fino a 10 carte e ridiscendendo.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const Spacer(),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('Nuova partita', style: textTheme.titleMedium),
                        const Spacer(),
                        const StatChip(icon: Icons.layers_rounded, value: '19 mani', color: AppColors.gold),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final players in const [2, 3, 4]) ...[
                          if (players > 2) const SizedBox(width: 10),
                          Expanded(
                            child: _PlayersOption(
                              players: players,
                              selected: _players == players,
                              onTap: () => setState(() => _players = players),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'La partita parte quando ci sono $_players giocatori.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'GIOCA',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => manager.joinGame(players: _players),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Come si gioca',
                icon: Icons.menu_book_rounded,
                style: AppButtonStyle.secondary,
                onPressed: () => showRulesSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One match size to choose from, drawn as that many little players.
class _PlayersOption extends StatelessWidget {
  final int players;
  final bool selected;
  final VoidCallback onTap;

  const _PlayersOption({required this.players, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Partita a $players giocatori',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold.withValues(alpha: 0.14) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: selected ? AppColors.gold : AppColors.border, width: selected ? 1.6 : 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (var i = 0; i < players; i++) Icon(Icons.person_rounded, size: 16, color: color)],
              ),
              const SizedBox(height: 4),
              Text('$players', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text('giocatori', style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
