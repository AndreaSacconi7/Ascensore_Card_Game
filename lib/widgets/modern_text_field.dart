import 'package:flutter/material.dart';

/// Rounded text field used by the login and nickname forms.
class ModernTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

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
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),

        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),

        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.green[400]!,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      ),
    );
  }
}