import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ascensore_client/pages/choose_nickname_page.dart';
import 'package:ascensore_client/pages/game_over_screen.dart';
import 'package:ascensore_client/pages/game_screen.dart';
import 'package:ascensore_client/pages/loading_screen.dart';
import 'package:ascensore_client/pages/login_page.dart';
import 'package:ascensore_client/pages/main_menu_screen.dart';

import 'app_screen_state.dart';
import 'client_manager.dart';
import 'network/server_link.dart';

/// Picks the page for the current screen and shows a banner while the connection is being restored.
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = context.select<ClientManager, AppScreenState>((m) => m.currentScreen);
    final linkState = context.select<ClientManager, LinkState>((m) => m.linkState);

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(screen),
        ),
        if (linkState == LinkState.reconnecting) const _ReconnectingBanner(),
      ],
    );
  }

  Widget _buildScreen(AppScreenState state) {
    switch (state) {
      case AppScreenState.loading:
        return const LoadingScreen();
      case AppScreenState.login:
        return const LoginPage();
      case AppScreenState.chooseNickname:
        return const ChooseNicknamePage();
      case AppScreenState.mainMenu:
        return const MainMenuScreen();
      case AppScreenState.inGame:
        return const GameScreen();
      case AppScreenState.gameOver:
        return const GameOverScreen();
    }
  }
}

class _ReconnectingBanner extends StatelessWidget {
  const _ReconnectingBanner();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Material(
          color: Colors.orange.shade800,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Connessione persa, riconnessione in corso…', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
