import 'package:flutter/material.dart';

/// Un bottone personalizzato per il menu, basato sul tuo stile.
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary; // Per lo stile (primario o secondario)
  final IconData? icon; // Icona opzionale

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = isPrimary
    // Stile Primario (verde)
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
    // Stile Secondario (trasparente con bordo)
        : OutlinedButton.styleFrom(
      foregroundColor: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 20),
      side: BorderSide(
        color: Colors.white.withOpacity(0.3),
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
