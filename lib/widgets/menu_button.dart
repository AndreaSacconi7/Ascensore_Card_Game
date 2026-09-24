
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary; // Per differenziare lo stile (es. Start vs Altri)

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    // Colori per i bottoni
    final primaryColor = Colors.green[600]; // Verde per Start
    final secondaryColor = Colors.white.withValues(alpha: 0.15); // Grigio/Trasparente
    final shadowColor = Colors.black.withValues(alpha: 0.3);

    return SizedBox(
      width: 280, // Larghezza fissa per tutti i bottoni
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : secondaryColor,
          foregroundColor: Colors.white, // Colore del testo
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Forma a pillola
          ),
          elevation: 5, // Ombra
          shadowColor: shadowColor,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Spaziatura tra le lettere
          ),
        ),
        child: Text(text),
      ),
    );
  }
}