import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../model/player.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, clientManager, child) {
        final game = clientManager.game;
        if (game == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        final sortedPlayers = _sortPlayersByScore(game.players);
        final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;
        final bool didWin = winner != null && winner == clientManager.mySelfPlayer;

        return Scaffold(
          backgroundColor: didWin ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),

                  _buildResultHeader(didWin),

                  const SizedBox(height: 30),

                  Text(
                    "Classifica Finale",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: sortedPlayers.length,
                      itemBuilder: (context, index) {
                        final player = sortedPlayers[index];
                        final isWinner = index == 0;

                        return _buildPlayerCard(player, index + 1, isWinner);
                      },
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () => context.read<ClientManager>().backToMenu(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: didWin ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Torna al Menu",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultHeader(bool didWin) {
    return Column(
      children: [
        Icon(
          didWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
          size: 80,
          color: didWin ? Colors.amber : Colors.redAccent,
        ),
        const SizedBox(height: 10),
        Text(
          didWin ? "VITTORIA!" : "SCONFITTA",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: didWin ? Colors.green[800] : Colors.red[800],
            letterSpacing: 1.5,
          ),
        ),
        Text(
          didWin ? "Campione della partita!" : "Ritenta, andrà meglio.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, int rank, bool isFirst) {

    return Transform.scale(
      scale: isFirst ? 1.05 : 1.0,
      child: Card(
        elevation: isFirst ? 8 : 2,
        margin: EdgeInsets.symmetric(vertical: isFirst ? 12 : 6, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isFirst
              ? const BorderSide(color: Colors.amber, width: 2)
              : BorderSide.none,
        ),
        color: isFirst ? Colors.amber[50] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(isFirst ? 20.0 : 16.0),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFirst ? Colors.amber : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "#$rank",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFirst ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  player.nickname,
                  style: TextStyle(
                    fontSize: isFirst ? 22 : 16,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                      color: isFirst ? Colors.amber[800] : Colors.grey[700]
                  ),
                ),
              ),

              Text(
                "${player.score} pt",
                style: TextStyle(
                  fontSize: isFirst ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isFirst ? Colors.amber[800] : Colors.grey[700],
                ),
              ),

              if (isFirst) ...[
                const SizedBox(width: 10),
                const Icon(Icons.star, color: Colors.amber),
              ]
            ],
          ),
        ),
      ),
    );
  }

  List<Player> _sortPlayersByScore(List<Player> players) =>
      List.of(players)..sort((a, b) => b.score.compareTo(a.score));
}