import 'package:flutter/material.dart';

import '../../ui/theme.dart';

/// Points won or lost in the set that just ended.
class SetResultToast extends StatelessWidget {
  final bool won;
  final int delta;

  const SetResultToast({super.key, required this.won, required this.delta});

  @override
  Widget build(BuildContext context) {
    final color = won ? AppColors.success : AppColors.danger;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.sheet.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(won ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 44),
            const SizedBox(height: 8),
            Text(
              '${delta > 0 ? '+' : ''}$delta',
              style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.w900),
            ),
            Text(
              won ? 'Scommessa centrata!' : 'Scommessa mancata',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
