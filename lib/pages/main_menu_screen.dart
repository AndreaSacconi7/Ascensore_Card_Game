import 'package:flutter/material.dart';

import '../app_screen_state.dart';
import '../client_manager.dart';
import '../command/join_game_request.dart';
import '../command/command.dart';
import '../command/command_type.dart';
import '../widgets/menu_button.dart';

import 'package:provider/provider.dart';
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
                  child: Selector<ClientManager, String?>(
                    selector: (context, manager) => manager.mySelfPlayer?.nickname,
                    builder: (context, nickname, child) {
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                            final manager = Provider.of<ClientManager>(context, listen: false);

                            JoinGameRequest executable = JoinGameRequest(nickname: manager.mySelfPlayer!.nickname);
                            Command command = Command(
                              commandType: CommandType.JOIN_GAME_REQUEST,
                              executable: executable,
                            );

                            manager.setCurrentScreen(AppScreenState.inGame);

                            manager.sendCommand(command.toJson());

                            // Il server risponderà con STARTING_GAME quando la lobby è piena
                          },
                          isPrimary: true, // Stile diverso
                        ),
                        const SizedBox(height: 20),

                        MenuButton(
                          text: "LOGOUT",
                          onPressed: () {
                            final manager = Provider.of<ClientManager>(context, listen: false);
                            manager.logOut();
                          }
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

