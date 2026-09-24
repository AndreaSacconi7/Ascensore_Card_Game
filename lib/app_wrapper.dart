import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ascensore_client/pages/game_over_screen.dart';
import 'package:ascensore_client/pages/game_screen.dart';
import 'package:ascensore_client/pages/loading_screen.dart';
import 'package:ascensore_client/pages/login_page.dart';
import 'package:ascensore_client/pages/main_menu_screen.dart';

import 'app_screen_state.dart';
import 'client_manager.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    // Selector: ricostruisce solo quando cambia la schermata corrente
    return Selector<ClientManager, AppScreenState>(
      selector: (context, manager) => manager.currentScreen,

      builder: (context, currentScreen, child) {

        debugPrint("AppWrapper: Stato cambiato in $currentScreen");

        // AnimatedSwitcher aggiunge una transizione tra le pagine
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(currentScreen),
        );
      },
    );
  }

  Widget _buildScreen(AppScreenState state) {
    switch (state) {
      case AppScreenState.loading:
      //Mostra uno spinner mentre controlla il token
        return const LoadingScreen();

      case AppScreenState.login:
      // Mostra la pagina di login
        return const LoginPage();

      case AppScreenState.mainMenu:
      // Mostra il menu principale
        return const MainMenuScreen();

      case AppScreenState.inGame:
      // Mostra la pagina di gioco!
        return const GameScreen();

      case AppScreenState.gameOver:
      // Mostra la schermata di Game Over
        return const GameOverScreen();

    }
  }
}