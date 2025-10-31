import 'dart:async'; // Importato per Future
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importato per il token
import 'package:provider/provider.dart';
import 'package:test_socket/ClientManagerOld.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/pages/MainMenuScreen.dart';
import '../AuthState.dart';
import '../ClientManager.dart';
import '../command/Command.dart';
import '../command/CommandType.dart';
import '../command/LoginRequest.dart';
import '../model/MySelfPlayer.dart';
import '../widgets/MenuButton2.0.dart';
import '../widgets/ModernTextField.dart';
import 'HomePage.dart';
import 'MainMenuScreen.dart';

class LoginPage extends StatefulWidget {
  // 1. Rimuovi clientManager dal costruttore
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 2. Avvia il controllo del token all'inizio
    // Usiamo addPostFrameCallback per sicurezza, per assicurarci
    // che il 'context' sia pronto per il Provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientManager>(context, listen: false).checkLoginStatus();
    });
  }

  // 3. Tutta la logica di storage e navigazione è stata rimossa.
  // La pagina ora è molto più pulita.

  /// Logica per il login come ospite (ora chiama solo il manager)
  void _loginAsGuest(BuildContext context) {
    final username = _usernameController.text;

    // 4. Chiama il manager per avviare il login
    Provider.of<ClientManager>(context, listen: false).loginAsGuest(username);
  }

  /// Logica per Google (chiama il manager)
  void _loginWithGoogle() {
    Provider.of<ClientManager>(context, listen: false).loginWithGoogle();
  }

  /// Logica per Apple (chiama il manager)
  void _loginWithApple() {
    Provider.of<ClientManager>(context, listen: false).loginWithApple();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. USA CONSUMER PER ASCOLTARE I CAMBIAMENTI
    return Consumer<ClientManager>(
      builder: (context, manager, child) {

        // --- GESTIONE DEGLI EFFETTI COLLATERALI ---

        // EFFETTO 1: Login Riuscito -> Naviga
        if (manager.authState == AuthState.authenticated) {
          // Usiamo 'addPostFrameCallback' per navigare *dopo*
          // che il 'build' è completato, per evitare errori.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print("PASSO A MAIN MENU SCREEN");
              // Non passiamo più il manager, MainMenuScreen lo prenderà dal Provider
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MainMenuScreen(),
                ),
              );
            }
          });
          // Mostra uno spinner mentre prepari la navigazione
          return _buildLoadingScaffold();
        }

        // EFFETTO 2: Errore -> Mostra SnackBar
        if (manager.authError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(manager.authError!)),
            );
            // Resetta l'errore nel manager per non mostrarlo di nuovo
            manager.clearAuthError();
          });
        }

        // --- COSTRUZIONE DELLA UI ---

        // Se sta caricando (o stato iniziale), mostra spinner
        if (manager.authState == AuthState.loading ||
            manager.authState == AuthState.unknown) {
          return _buildLoadingScaffold();
        }

        // Altrimenti (unauthenticated, error), mostra la pagina di login
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D2671), Color(0xFF0A113E)],
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
                        "BENVENUTO",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // --- Login Social (Google) ---
                      MenuButton(
                        text: "Accedi con Google",
                        // Disabilita il bottone se sta caricando
                        onPressed: manager.authState == AuthState.loading
                            ? null
                            : _loginWithGoogle,
                        isPrimary: false,
                        icon: Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 20),

                      // --- Login Social (Game Center / Apple) ---
                      MenuButton(
                        text: "Accedi con Apple",
                        onPressed: manager.authState == AuthState.loading
                            ? null
                            : _loginWithApple,
                        isPrimary: false,
                        icon: Icons.apple,
                      ),
                      const SizedBox(height: 40),

                      // --- Divisore "OPPURE" ---
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "OPPURE",
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // --- Campo Username (Ospite) ---
                      ModernTextField(
                        controller: _usernameController,
                        hintText: "Inserisci username (Ospite)",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 24),

                      // --- Bottone Login (Ospite) ---
                      MenuButton(
                        text: "ENTRA COME OSPITE",
                        onPressed: manager.authState == AuthState.loading
                            ? null
                            : () => _loginAsGuest(context),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Un widget helper per mostrare lo scaffold di caricamento
  Widget _buildLoadingScaffold() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFF0A113E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}


