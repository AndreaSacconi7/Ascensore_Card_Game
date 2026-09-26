import 'package:flutter/material.dart';

import '../ui/theme.dart';

/// How to play, as a scrollable bottom sheet.
Future<void> showRulesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Come si gioca', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const _Rule(
            icon: Icons.unfold_more_rounded,
            title: 'L\'ascensore',
            text: 'Si gioca con il mazzo italiano da 40 carte. Nella prima mano hai 1 carta, poi 2, fino a 10; '
                'poi si scende di nuovo fino a 1. In tutto sono 19 mani.',
          ),
          const _Rule(
            icon: Icons.flag_rounded,
            title: 'La scommessa',
            text: 'All\'inizio di ogni mano, a turno, ognuno dice quante prese farà. L\'ultimo a scommettere '
                'non può far tornare il totale uguale al numero di carte in mano: qualcuno deve sbagliare.',
          ),
          const _Rule(
            icon: Icons.style_rounded,
            title: 'Le prese',
            text: 'Chi vince la presa apre la successiva. Devi rispondere al seme della prima carta, se ce l\'hai. '
                'Vince la briscola più alta; senza briscole, la carta più alta del seme di uscita.',
          ),
          const _Rule(
            icon: Icons.military_tech_rounded,
            title: 'Forza delle carte',
            text: 'Asso, Tre, Re, Cavallo, Fante, poi dal 7 al 2.',
          ),
          const _Rule(
            icon: Icons.auto_awesome_rounded,
            title: 'La mano da 10',
            text: 'Con 10 carte a testa non si scopre la briscola: diventa briscola il seme della prima carta '
                'giocata in ogni presa.',
          ),
          const _Rule(
            icon: Icons.star_rounded,
            title: 'Punti',
            text: 'Scommessa centrata: 10 punti più 10 per ogni presa. Scommessa mancata: meno 10 per ogni presa '
                'di differenza. Vince chi ha più punti dopo la diciannovesima mano.',
          ),
        ],
      ),
    ),
  );
}

class _Rule extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Rule({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
