import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_socket/pages/GameScreen.dart';
import 'package:test_socket/pages/LoadingScreen.dart';
import 'package:test_socket/pages/LoginPage.dart';
import 'package:test_socket/pages/MainMenuScreen.dart';

import 'AppScreenState.dart';
import 'ClientManager.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    // 1. Usiamo Selector per ascoltare SOLO lo stato dello schermo
    return Selector<ClientManager, AppScreenState>(
      selector: (context, manager) => manager.currentScreen,

      builder: (context, currentScreen, child) {

        print("AppWrapper: Stato cambiato in $currentScreen");

        // 2. Usiamo un 'switch' per decidere quale pagina mostrare
        //    AnimatedSwitcher aggiunge una bella transizione
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(currentScreen),
        );
      },
    );
  }

  // 3. Funzione di supporto per restituire la pagina corretta
  Widget _buildScreen(AppScreenState state) {
    switch (state) {
      case AppScreenState.loading:
      //Mostra uno spinner mentre controlla il token
        return LoadingScreen(); // Sostituisci con la tua schermata di caricamento

      case AppScreenState.login:
      // Mostra la pagina di login
        return LoginPage(); // Sostituisci con la tua LoginPage

      case AppScreenState.mainMenu:
      // Mostra il menu principale
        return MainMenuScreen(); // Sostituisci con la tua MainMenuScreen

      case AppScreenState.inGame:
      // Mostra la pagina di gioco!
        return GameScreen(); // Sostituisci con la tua pagina di gioco

      default:
      // Fallback
        return LoginPage();
    }
  }
}