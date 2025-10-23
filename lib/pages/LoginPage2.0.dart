import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';

import '../widgets/MenuButton.dart';


class LoginPage extends StatelessWidget {
  ClientManager clientManager;
  LoginPage({super.key, required this.clientManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Stesso gradiente del menu per coerenza
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D2671), // Blu/Viola scuro
              Color(0xFF0A113E), // Blu notte
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Titolo ---
                  Text(
                    "ACCEDI",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Campo Email ---
                  const _ModernTextField(
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // --- Campo Password ---
                  const _ModernTextField(
                    hintText: "Password",
                    icon: Icons.lock_outlined,
                    isPassword: true,
                  ),
                  const SizedBox(height: 12),

                  // --- Password Dimenticata ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Logica password dimenticata
                      },
                      child: Text(
                        "Password dimenticata?",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Bottone Login ---
                  MenuButton(
                    text: "LOGIN",
                    onPressed: () {
                      // Logica di login
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(height: 40),

                  // --- Testo per Registrarsi ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Non hai un account? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          // Logica per andare alla pagina di registrazione
                        },
                        child: Text(
                          "Registrati",
                          style: TextStyle(
                            color: Colors.green[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un widget personalizzato per i campi di testo moderni
class _ModernTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const _ModernTextField({
    required this.hintText,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        // Stile del testo "hint"
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),

        // Icona a sinistra
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),

        // Sfondo del campo
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),

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
