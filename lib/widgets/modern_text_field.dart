import 'package:flutter/material.dart';

/// Un widget personalizzato per i campi di testo moderni
class ModernTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller; // Aggiunto per il guest

  const ModernTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        // Stile del testo "hint"
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),

        // Icona a sinistra
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),

        // Sfondo del campo
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),

        // Bordi
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // Nessun bordo quando non in focus
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.green[400]!, // Bordo verde quando selezionato
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      ),
    );
  }
}