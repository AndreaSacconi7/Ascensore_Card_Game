
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green[600];
    final secondaryColor = Colors.white.withValues(alpha: 0.15);
    final shadowColor = Colors.black.withValues(alpha: 0.3);

    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 5,
          shadowColor: shadowColor,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}