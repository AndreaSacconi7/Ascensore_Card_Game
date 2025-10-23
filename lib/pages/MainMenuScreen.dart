import 'package:flutter/material.dart';
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
import 'package:test_socket/pages/LoginPage.dart';
import 'package:test_socket/pages/PageInterface.dart';

import '../ClientManager.dart';
import '../widgets/MenuButton.dart';
import 'HomePage.dart';

class MainMenuScreen extends StatelessWidget implements PageInterface {
  final ClientManager clientManager;

  MainMenuScreen(this.clientManager, {super.key}){
    clientManager.setCurrentPage(this);
  }

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
                  child: Row(
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
                      // Nome Giocatore
                      Text(
                        "PlayerName123",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(clientManager: clientManager),
                              ),
                            );
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
                            /*Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(),
                              ),
                            );*/
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

  @override
  handleBriscolaUpdate(BriscolaUpdate briscolaUpdate) {
    // TODO: implement handleBriscolaUpdate
    throw UnimplementedError();
  }

  @override
  handleEndRoundUpdate(EndRoundUpdate endRoundUpdate) {
    // TODO: implement handleEndRoundUpdate
    throw UnimplementedError();
  }

  @override
  handleEndSetUpdate(EndSetUpdate endSetUpdate) {
    // TODO: implement handleEndSetUpdate
    throw UnimplementedError();
  }

  @override
  handleHandUpdate(HandUpdate handUpdate) {
    // TODO: implement handleHandUpdate
    throw UnimplementedError();
  }

  @override
  handleLoginResponse(LoginResponse response) {
    // TODO: implement handleLoginResponse
    throw UnimplementedError();
  }

  @override
  handlePlayedCard(PlayedCardUpdate playedCardUpdate) {
    // TODO: implement handlePlayedCard
    throw UnimplementedError();
  }

  @override
  handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate) {
    // TODO: implement handlePlayerStateUpdate
    throw UnimplementedError();
  }

  @override
  handleSettedBet(SettedBetUpdate settedBetUpdate) {
    // TODO: implement handleSettedBet
    throw UnimplementedError();
  }

  @override
  handleStartingGame(StartingGame startingGame) {
    // TODO: implement handleStartingGame
    throw UnimplementedError();
  }

  @override
  handleTextMessage(TextMessage textMessage) {
    // TODO: implement handleTextMessage
    throw UnimplementedError();
  }
}