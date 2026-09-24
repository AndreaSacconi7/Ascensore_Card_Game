import 'dart:async'; // Importato per Future
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importato per il token
import 'package:provider/provider.dart';
import 'package:test_socket/ClientManagerOld.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/pages/MainMenuScreen.dart';
import '../AuthenticationState.dart';
import '../ClientManager.dart';
import '../command/Command.dart';
import '../command/CommandType.dart';
import '../command/LoginRequest.dart';
import '../model/MySelfPlayer.dart';
import '../widgets/MenuButton2.0.dart';
import '../widgets/ModernTextField.dart';
import 'HomePageOld.dart';
import 'MainMenuScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller per i vari campi
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Stato locale per gestire se l'utente vuole fare Login o Registrazione
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientManager>(context, listen: false).checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGICA DI LOGIN ---

  /// Login con Email e Password
  void _submitEmailAuth(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci email e password")),
      );
      return;
    }

    final manager = Provider.of<ClientManager>(context, listen: false);

    if (_isLoginMode) {
      // Chiama il metodo di Login nel manager
      manager.loginWithEmail(email, password);
    } else {
      // Chiama il metodo di Registrazione nel manager
      manager.signUpWithEmail(email, password);
    }
  }

  void _loginAsGuest(BuildContext context) {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci uno username per l'ospite")),
      );
      return;
    }
    Provider.of<ClientManager>(context, listen: false).loginAsGuest(username);
  }

  void _loginWithGoogle() {
    Provider.of<ClientManager>(context, listen: false).loginWithGoogle();
  }

  void _loginWithApple() {
    Provider.of<ClientManager>(context, listen: false).loginWithApple();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, manager, child) {

        // Gestione Errori
        if (manager.authError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(manager.authError!)),
            );
            manager.clearAuthError();
          });
        }

        // Gestione Loading
        if (manager.authState == AuthenticationState.loading ||
            manager.authState == AuthenticationState.unknown) {
          return _buildLoadingScaffold();
        }

        // UI Principale
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
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLoginMode ? "BENTORNATO" : "CREA ACCOUNT",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- SEZIONE EMAIL & PASSWORD ---
                      ModernTextField(
                        controller: _emailController,
                        hintText: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 24),

                      // Bottone Login/Registrati
                      MenuButton(
                        text: _isLoginMode ? "ACCEDI CON EMAIL" : "REGISTRATI",
                        onPressed: manager.authState == AuthenticationState.loading
                            ? null
                            : () => _submitEmailAuth(context),
                        isPrimary: true, // Colore principale per l'azione email
                      ),

                      // Toggle Login/Registrazione
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                        child: Text(
                          _isLoginMode
                              ? "Non hai un account? Registrati"
                              : "Hai già un account? Accedi",
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildDivider("SOCIAL"),
                      const SizedBox(height: 20),

                      // --- SEZIONE SOCIAL ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Usiamo versioni più piccole o icone se preferisci,
                          // altrimenti mantieni i MenuButton full width
                          Expanded(
                            child: MenuButton(
                              text: "Google",
                              onPressed: _loginWithGoogle,
                              isPrimary: false,
                              icon: Icons.g_mobiledata,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MenuButton(
                              text: "Apple",
                              onPressed: _loginWithApple,
                              isPrimary: false,
                              icon: Icons.apple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _buildDivider("OPPURE"),
                      const SizedBox(height: 30),

                      // --- SEZIONE OSPITE ---
                      ModernTextField(
                        controller: _usernameController,
                        hintText: "Nickname (Ospite)",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      MenuButton(
                        text: "ENTRA COME OSPITE",
                        onPressed: manager.authState == AuthenticationState.loading
                            ? null
                            : () => _loginAsGuest(context),
                        isPrimary: false, // Meno enfasi sull'ospite ora
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

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      ],
    );
  }

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


