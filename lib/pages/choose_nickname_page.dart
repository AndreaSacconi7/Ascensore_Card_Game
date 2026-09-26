import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../message/player_info_response.dart';
import '../widgets/form_button.dart';
import '../widgets/modern_text_field.dart';

/// Shown once per account: the public name other players see (never the email address).
class ChooseNicknamePage extends StatefulWidget {
  const ChooseNicknamePage({super.key});

  /// Same rule as the server: 3 to 16 letters, digits or underscores.
  static final nicknamePattern = RegExp(r'^[A-Za-z0-9_]{3,16}$');

  @override
  State<ChooseNicknamePage> createState() => _ChooseNicknamePageState();
}

class _ChooseNicknamePageState extends State<ChooseNicknamePage> {
  final _controller = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(ClientManager manager) {
    final nickname = _controller.text.trim();
    if (!ChooseNicknamePage.nicknamePattern.hasMatch(nickname)) {
      setState(() => _localError = 'Da 3 a 16 caratteri: lettere, numeri o _');
      return;
    }
    setState(() => _localError = null);
    manager.submitNickname(nickname);
  }

  String? _serverErrorText(String? code) {
    switch (code) {
      case PlayerInfoResponse.nicknameTaken:
        return 'Nickname già in uso, scegline un altro';
      case PlayerInfoResponse.nicknameInvalid:
        return 'Da 3 a 16 caratteri: lettere, numeri o _';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ClientManager>();
    final error = _localError ?? _serverErrorText(manager.nicknameError);

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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SCEGLI UN NICKNAME',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'È il nome che vedranno gli altri giocatori.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 30),
                  ModernTextField(
                    controller: _controller,
                    hintText: 'Nickname',
                    icon: Icons.person_outline,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[200])),
                  ],
                  const SizedBox(height: 24),
                  FormButton(
                    text: 'CONFERMA',
                    isPrimary: true,
                    onPressed: manager.submittingNickname ? null : () => _submit(manager),
                  ),
                  TextButton(
                    onPressed: manager.logOut,
                    child: Text('Esci', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
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
