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

import '../ClientManager.dart';
import '../ClientManagerOld.dart';
import '../command/Command.dart';
import '../command/CommandType.dart';
import '../widgets/MenuButton.dart';
import 'HomePage.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Assicurati di importare il tuo ClientManager e MenuButton
// import 'client_manager.dart';
// import 'menu_button.dart';

// 1. Rimuovi 'implements PageInterface'
class MainMenuScreen extends StatelessWidget {

  // 2. Rimuovi 'clientManager' e 'token' dal costruttore.
  // La logica (PlayerInfoRequest) è stata spostATA nel ClientManager.
  const MainMenuScreen({super.key});

  // 3. Rimuovi la funzione '_sendCommand'

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
                  // 4. USA UN SELECTOR (o Consumer) per ottenere i dati
                  child: Selector<ClientManager, String?>(
                    // 5. Seleziona SOLO il nickname
                    selector: (context, manager) => manager.mySelfPlayer?.nickname,

                    // 6. Il builder si aggiorna solo quando il nickname cambia
                    builder: (context, nickname, child) {
                      return Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Nome Giocatore (ora dinamico!)
                          Text(
                            nickname ?? "Caricamento...", // Mostra il nickname
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
                            // Logica per avviare il gioco
                            print("Start Game premuto");
                            // TODO: Naviga alla schermata di gioco
                            // Navigator.pushNamed(context, '/game');
                          },
                          isPrimary: true, // Stile diverso
                        ),
                        const SizedBox(height: 20),

                        // Bottone Classifica
                        MenuButton(
                          text: "CLASSIFICA",
                          onPressed: () {
                            // Logica per mostrare la classifica
                            print("Classifica premuta");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Bottone Offline
                        MenuButton(
                          text: "OFFLINE",
                          onPressed: () {
                            // Logica per modalità offline
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

