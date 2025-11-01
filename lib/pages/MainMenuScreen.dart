import 'package:flutter/material.dart';
import 'package:test_socket/command/PlayerInfoRequest.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/EndRoundUpdate.dart';
import 'package:test_socket/message/EndSetUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/message/PlayedCardUpdate.dart';
import 'package:test_socket/message/PlayerStateUpdate.dart';
import 'package:test_socket/message/SettedBetUpdate.dart';
import 'package:test_socket/message/StartingGame.dart';
import 'package:test_socket/message/TextMessage.dart';
import 'package:test_socket/pages/LoginPageOld.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../AppScreenState.dart';
import '../ClientManager.dart';
import '../ClientManagerOld.dart';
import '../command/AddPlayerToGame.dart';
import '../command/Command.dart';
import '../command/CommandType.dart';
import '../widgets/MenuButton.dart';
import 'HomePageOld.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Assicurati di importare il tuo ClientManager e MenuButton
// import 'client_manager.dart';
// import 'menu_button.dart';

// 1. Rimuovi 'implements PageInterface'
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Sfondo con gradiente moderno
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- Sezione 1: Info Giocatore (Alto a Sinistra) ---
                Align(
                  alignment: Alignment.topLeft,
                  // 1. "ASCOLTARE" - Questo è per la UI
                  child: Selector<ClientManager, String?>(
                    selector: (context, manager) => manager.mySelfPlayer?.nickname,
                    builder: (context, nickname, child) {
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.person, size: 35, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            nickname ?? "Caricamento...",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // --- Sezione 2: Bottoni (Centrati) ---
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Per contrarre la colonna
                      children: [
                        // Bottone Start Game (Primario)
                        MenuButton(
                          text: "START GAME",
                          onPressed: () {
                            // 2. "CHIAMARE" - Questo è per le AZIONI
                            print("Start Game premuto");

                            // 2a. Ottieni il manager (SENZA ascoltare)
                            final manager = Provider.of<ClientManager>(context, listen: false);

                            // 2b. Crea il comando (logica che prima era in _sendCommand)
                            AddPlayerToGame executable = AddPlayerToGame(nickname: manager.mySelfPlayer!.nickname);
                            Command command = Command(
                              commandType: CommandType.ADD_PLAYER_TO_GAME, // Esempio
                              executable: executable,
                            );

                            manager.setCurrentScreen(AppScreenState.inGame);

                            // 2c. Invoca il metodo sul manager
                            manager.sendCommand(command.toJson());

                            // Il ClientManager riceverà poi un messaggio
                            // "STARTING_GAME", cambierà lo stato in 'AppScreenState.inGame',
                            // e l'AppWrapper si occuperà di navigare.
                          },
                          isPrimary: true, // Stile diverso
                        ),
                        const SizedBox(height: 20),

                        // Bottone Classifica
                        MenuButton(
                          text: "CLASSIFICA",
                          onPressed: () {
                            print("Classifica premuta");
                            // Esempio:
                            // final manager = Provider.of<ClientManager>(context, listen: false);
                            // manager.requestLeaderboard();
                          },
                        ),
                        const SizedBox(height: 20),

                        // Bottone Offline
                        MenuButton(
                          text: "OFFLINE",
                          onPressed: () {
                            print("Offline premuto");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

