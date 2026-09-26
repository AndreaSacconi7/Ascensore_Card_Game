import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../ui/components.dart';
import '../ui/game_widgets.dart';
import '../ui/theme.dart';
import 'rules_sheet.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
              const Center(child: DecorativeCardFan(cardWidth: 84)),
              const SizedBox(height: 28),
              const Center(child: AppLogo(height: 46)),
              const SizedBox(height: 10),
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
                        const Icon(Icons.bolt_rounded, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text('Partita veloce', style: textTheme.titleMedium),
                        const Spacer(),
                        const StatChip(icon: Icons.layers_rounded, value: '19 mani', color: AppColors.gold),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Entri in coda e la partita parte appena si trova un avversario.',
                        style: textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    AppButton(label: 'GIOCA', icon: Icons.play_arrow_rounded, onPressed: manager.joinGame),
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
