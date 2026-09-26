import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../widgets/menu_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D2671),
              Color(0xFF0A113E),
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
                // Player name, top left
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

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MenuButton(
                          text: "START GAME",
                          // The game screen waits until the server sends STARTING_GAME
                          onPressed: () => context.read<ClientManager>().joinGame(),
                          isPrimary: true,
                        ),
                        const SizedBox(height: 20),

                        MenuButton(
                          text: "LOGOUT",
                          onPressed: () => context.read<ClientManager>().logOut(),
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

