import 'package:flutter/material.dart';

/// Full-width button for forms (login, nickname), with an optional icon.
class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;

  const FormButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = isPrimary
        ? ElevatedButton.styleFrom(
      backgroundColor: Colors.green[400],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    )
        : OutlinedButton.styleFrom(
      foregroundColor: Colors.white.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(vertical: 20),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.3),
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 12),
        ],
        Text(text.toUpperCase()),
      ],
    );

    return isPrimary
        ? ElevatedButton(onPressed: onPressed, style: style, child: content)
        : OutlinedButton(onPressed: onPressed, style: style, child: content);
  }
}
