import 'dart:async'; // Importato per Future
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importato per il token
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/pages/MainMenuScreen.dart';
import '../widgets/MenuButton2.0.dart';
import '../widgets/ModernTextField.dart';
import 'MainMenuScreen.dart';


class LoginPage extends StatefulWidget {
  final ClientManager clientManager;

  const LoginPage({super.key, required this.clientManager});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true; // Mostra il caricamento all'inizio

  @override
  void initState() {
    super.initState();
    // Controlla se l'utente ha già un token per il login automatico
    _checkLoginStatus();
  }

  /// Controlla se un token è già salvato e naviga alla schermata principale
  Future<void> _checkLoginStatus() async {
    // Prova a leggere il token
    final token = await _storage.read(key: 'auth_token');

    // Assicurati che il widget sia ancora "montato" prima di navigare
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Token trovato! Esegui il login automatico
      print("Token trovato, login automatico...");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainMenuScreen(widget.clientManager)),
      );
    } else {
      // Nessun token, mostra la pagina di login
      print("Nessun token, mostro la pagina di login.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Salva il token in modo sicuro e naviga alla schermata principale
  Future<void> _saveTokenAndNavigate(String token) async {
    await _storage.write(key: 'auth_token', value: token);

    if (!mounted) return;
    /*Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );*/
  }

  /// Logica per il login come ospite
  void _loginAsGuest() {
    final username = _usernameController.text;
    if (username.isEmpty) {
      // Mostra un errore se il nome utente è vuoto
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, inserisci uno username')),
      );
      return;
    }

    // --- QUI VA LA TUA LOGICA SOCKET ---
    // 1. Invia 'username' al tuo server...
    // 2. Il server risponde con un token...
    print("Invio '$username' al server...");

    // 3. Simula la ricezione di un token dal server
    final mockToken = "mock_token_for_${username}_${DateTime.now().millisecondsSinceEpoch}";
    print("Token ricevuto: $mockToken");

    // 4. Salva il token e naviga
    _saveTokenAndNavigate(mockToken);
  }

  /// Qui inserirai la logica dell'SDK di Google
  void _loginWithGoogle() {
    print("Avvio login con Google...");
    // 1. Chiama l'SDK di Google
    // 2. Ottieni l'idToken di Google
    // 3. Invialo al tuo server
    // 4. Ricevi il tuo token personalizzato dal server
    // 5. Chiama _saveTokenAndNavigate(tuoToken)
  }

  /// Qui inserirai la logica di Sign in with Apple (Game Center è per le classifiche)
  void _loginWithApple() {
    print("Avvio login con Apple/Game Center...");
    // 1. Chiama l'SDK 'sign_in_with_apple'
    // 2. Ottieni le credenziali
    // 3. Invia al tuo server
    // 4. Ricevi il tuo token personalizzato
    // 5. Chiama _saveTokenAndNavigate(tuoToken)
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Se sta caricando, mostra uno spinner
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
            // Altrimenti, mostra il contenuto della pagina
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Titolo ---
                  Text(
                    "BENVENUTO",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Login Social (Google) ---
                  MenuButton(
                    text: "Accedi con Google",
                    onPressed: _loginWithGoogle,
                    isPrimary: false,
                    icon: Icons.g_mobiledata, // Sostituisci con l'icona di Google
                  ),
                  const SizedBox(height: 20),

                  // --- Login Social (Game Center / Apple) ---
                  MenuButton(
                    text: "Accedi con Apple", // O Game Center
                    onPressed: _loginWithApple,
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
                    controller: _usernameController, // Aggiunto controller
                    hintText: "Inserisci username (Ospite)",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),

                  // --- Bottone Login (Ospite) ---
                  MenuButton(
                    text: "ENTRA COME OSPITE",
                    onPressed: _loginAsGuest,
                    isPrimary: true,
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
