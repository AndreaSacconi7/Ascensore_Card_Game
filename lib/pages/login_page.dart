import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication_state.dart';
import '../client_manager.dart';
import '../widgets/form_button.dart';
import '../widgets/modern_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Whether the form signs in or creates an account
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      manager.loginWithEmail(email, password);
    } else {
      manager.signUpWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, manager, child) {

        // Show a pending error once
        if (manager.authError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(manager.authError!)),
            );
            manager.clearAuthError();
          });
        }

        if (manager.authState == AuthenticationState.loading ||
            manager.authState == AuthenticationState.unknown) {
          return _buildLoadingScaffold();
        }

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
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      FormButton(
                        text: _isLoginMode ? "ACCEDI CON EMAIL" : "REGISTRATI",
                        onPressed: manager.authState == AuthenticationState.loading
                            ? null
                            : () => _submitEmailAuth(context),
                        isPrimary: true,
                      ),

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
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                        ),
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


