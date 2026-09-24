import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ascensore_client/model/player_state.dart';
import 'package:ascensore_client/model/set_result_animation_state.dart';

import '../client_manager.dart';
import '../command/command.dart';
import '../command/command_type.dart';
import '../command/put_card.dart';
import '../command/set_bet.dart';
import '../model/card_game.dart';
import '../model/game.dart';
import '../model/game_rules.dart';
import '../model/player.dart';
import '../widgets/card_widget.dart';
import '../widgets/hand_cards.dart';
import '../widgets/my_self_taken_bet_score.dart';
import '../widgets/played_card_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/set_result_animation.dart';

class GameScreen extends StatefulWidget {
  // NON riceve più ClientManager
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // NON c'è più 'Game game = Game()'
  // NON c'è più 'initState' con dati di test
  // NON ci sono più metodi 'handle...'

  CardGame? droppedCard; // Questo è ok, è stato UI locale

  // Breakpoint per il layout responsive
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 900.0;

  // --- LOGICA NUOVA: Listener per reagire ai cambi di stato ---
  ClientManager? _clientManager; // Riferimento al manager
  PlayerState? _previousPlayerState; // Stato precedente per confronto

  SetResultAnimationState _uiAnimationState = SetResultAnimationState.none;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ottieni il manager, ma non ascoltare (Consumer lo fa per il build)
    final manager = Provider.of<ClientManager>(context, listen: false);

    // Se è la prima volta o il manager è cambiato,
    // rimuovi il vecchio listener e aggiungi il nuovo.
    if (manager != _clientManager) {
      _clientManager?.removeListener(_handleClientChanges); // Pulisci vecchio
      _clientManager = manager;
      _clientManager?.addListener(_handleClientChanges); // Ascolta nuovo

      // Salva lo stato iniziale
      _previousPlayerState = _clientManager?.mySelfPlayer?.playerState;
    }
  }

  @override
  void dispose() {
    // Rimuovi il listener quando la pagina viene distrutta
    _clientManager?.removeListener(_handleClientChanges);
    super.dispose();
  }

  /// Questa funzione viene chiamata OGNI VOLTA che
  /// il ClientManager chiama notifyListeners()
  void _handleClientChanges() {
    debugPrint("_handleClientChanges called in GameScreen");
    debugPrint("Previous State: $_previousPlayerState");
    debugPrint("Current State: ${_clientManager?.mySelfPlayer?.playerState}");

    if (!mounted) return; // Non fare nulla se la pagina è stata distrutta

    final mySelfPlayer = _clientManager?.mySelfPlayer;
    if (mySelfPlayer == null) return;

    // Ottieni lo stato attuale
    final currentState = mySelfPlayer.playerState;

    // IL "TRIGGER": Lo stato è appena cambiato in BET?
    if (currentState == PlayerState.BET &&
        _previousPlayerState != PlayerState.BET) {

      // Sì! Chiama la funzione per mostrare l'overlay
      // Dobbiamo passare manager e game presi da _clientManager
      final game = _clientManager!.game;
      if (game != null) {
        // Usiamo un micro-ritardo (Future.microtask) per assicurarci
        // che il 'build' corrente sia finito prima di mostrare un Dialog
        Future.microtask(() {
          if (mounted) { // Controlla di nuovo se il widget è ancora montato
            _showBetOverlay(context, _clientManager!, game);
          }
        });
      }
    }

    // Aggiorna lo stato precedente per il prossimo controllo
    _previousPlayerState = currentState;

    // Leggiamo lo stato dal manager
    final resultFromManager = _clientManager?.lastSetResult;

    // Se il manager ci dice che c'è un risultato (Win o Loss)
    // E noi non stiamo già mostrando quell'animazione...
    if (resultFromManager != SetResultAnimationState.none &&
        resultFromManager != _uiAnimationState) {

      setState(() {
        _uiAnimationState = resultFromManager!;
      });
    }

    // Se il manager ha resettato a 'none' (dopo i 3 secondi), resettiamo anche noi
    if (resultFromManager == SetResultAnimationState.none &&
        _uiAnimationState != SetResultAnimationState.none) {
      setState(() {
        _uiAnimationState = SetResultAnimationState.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, manager, child) {

        final game = manager.game;
        final mySelfPlayer = manager.mySelfPlayer;

        // Partita non ancora caricata: spinner
        if (game == null || mySelfPlayer == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("In attesa dei dati di gioco..."),
                ],
              ),
            ),
          );
        }

        final double screenWidth = MediaQuery.of(context).size.width;

        if (screenWidth >= desktopBreakpoint) {
          // --- Layout per PC/Desktop ---
          return Scaffold(
            body: Stack(
              children: [
                _buildDropZone(context, manager, game), // Passiamo manager e game
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),
                      _buildPlayersRow(context, manager, game), // Passiamo
                      const Spacer(flex: 4),
                      _buildTopCardRow(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      _buildMiddleRow(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      _buildMySelfPlayedCardRowDesktop(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      const Expanded(
                        flex: 15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            HandCards(), // HandCards ora usa Selector, quindi non serve passare dati
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // --- Layout per Mobile ---
          return Scaffold(
            body: Stack(
              children: [
                _buildDropZone(context, manager, game), // Passiamo
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),
                      _buildPlayersRow(context, manager, game), // Passiamo
                      const Spacer(flex: 4),
                      _buildTopCardRow(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      _buildMiddleRow(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      _buildMySelfPlayedCardRow(context, manager, game), // Passiamo
                      const Spacer(flex: 3),
                      _buildBetAndTakenRow(context, manager, game), // Passiamo
                      const Expanded(
                        flex: 15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            HandCards(), // Corretto
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // WIDGET ANIMAZIONE
                if (_uiAnimationState != SetResultAnimationState.none)
                  Positioned.fill(
                    child: Center(
                      child: SetResultAnimation(
                        // Passiamo true se è WIN, false se è LOSS
                        isWin: _uiAnimationState == SetResultAnimationState.win,
                        onComplete: () {},
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  // --- Tutti i metodi helper ora ricevono manager e game ---

  Widget _buildPlayersRow(BuildContext context, ClientManager manager, Game game) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double spacing = (screenWidth > tabletBreakpoint) ? 100.0 : 8.0;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: 8.0,
      children: game.players.isNotEmpty
          ? game.players
                .where((player) => player.getNickname() != manager.mySelfPlayer!.nickname)
                .map((player) => PlayerWidget(
                    name: player.getNickname(),
                    avatarUrl: "default_avatar_url",
                    player: player,
                  ))
                .toList()
          : [const Text('No players available yet')],
    );
  }

  // Restituisce una lista di giocatori escludendo "me stesso"
  List<Player> _getOpponents(ClientManager manager, Game game) {
    return game.players
        .where((p) => p.nickname != manager.mySelfPlayer!.nickname)
        .toList();
  }

  Widget _buildTopCardRow(BuildContext context, ClientManager manager, Game game) {
    final opponents = _getOpponents(manager, game);
    final topPlayer = opponents.isNotEmpty ? opponents[0] : null;

    return topPlayer?.playedCardNotifier.value != null && topPlayer?.nickname != manager.mySelfPlayer!.nickname
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlayedCardWidget(playedCardNotifier: topPlayer!.playedCardNotifier)],
    )
        : const SizedBox.shrink();
  }

  Widget _buildMiddleRow(BuildContext context, ClientManager manager, Game game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayerCard(context, manager, game, 1),
        const SizedBox(width: 60),
        _buildBriscolaCard(context, manager, game),
        const SizedBox(width: 60),
        _buildPlayerCard(context, manager, game, 2),
      ],
    );
  }

  Widget _buildMySelfPlayedCardRow(BuildContext context, ClientManager manager, Game game) {
    final mySelfPlayer = manager.mySelfPlayer;
    return mySelfPlayer?.playedCardNotifier.value != null
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlayedCardWidget(playedCardNotifier: mySelfPlayer!.playedCardNotifier),
      ],
    )
        : const SizedBox.shrink();
  }

  Widget _buildMySelfPlayedCardRowDesktop(BuildContext context, ClientManager manager, Game game) {
    final mySelfPlayer = manager.mySelfPlayer;
    final Widget centeredWidget = mySelfPlayer?.playedCardNotifier.value != null
        ? PlayedCardWidget(playedCardNotifier: mySelfPlayer!.playedCardNotifier)
        : const SizedBox.shrink();

    return Stack(
      children: [
        Center(child: centeredWidget),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildBetAndTakenRow(context, manager, game),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, ClientManager manager, Game game, int playerIndex) {
    final opponents = _getOpponents(manager, game);

    final player = opponents.length > playerIndex ? opponents[playerIndex] : null;
    return player?.playedCardNotifier.value != null && player?.nickname != manager.mySelfPlayer!.nickname
        ? PlayedCardWidget(playedCardNotifier: player!.playedCardNotifier)
        : const SizedBox.shrink();
  }

  Widget _buildBriscolaCard(BuildContext context, ClientManager manager, Game game) {
    return game.briscola != null
        ? CardWidget(card: game.briscola!)
        : const SizedBox.shrink();
  }

  void _showBetOverlay(BuildContext context, ClientManager manager, Game game) {
    // Ora il context è corretto perché viene dalla pagina
    double sliderValue = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) { // Usa un context diverso per il dialog
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Set your bet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Slider(
                      value: sliderValue,
                      min: 0,
                      max: game.getSet().toDouble(),
                      divisions: game.getSet(),
                      label: sliderValue.toStringAsFixed(0),
                      onChanged: (double value) => setState(() => sliderValue = value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (checkIfValidBet(context, manager, game, sliderValue.toInt())) {
                          Navigator.of(dialogContext).pop(); // Chiudi il dialog

                          // Server-authoritative: lo stato si aggiorna solo alla risposta del server
                          SetBet setBetExecutable = SetBet(bet: sliderValue.toInt(), nickname: manager.mySelfPlayer!.getNickname());
                          Command command = Command(
                            commandType: CommandType.SET_BET,
                            executable: setBetExecutable,
                            nickName: manager.mySelfPlayer!.getNickname(),
                          );
                          manager.sendCommand(command.toJson());
                        } else {
                          showMessage('Invalid bet! Please choose a different value.');
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBetAndTakenRow(BuildContext context, ClientManager manager, Game game) {
    return Row(
      children: [
        MySelfBetTakenScoreWidget(player: manager.mySelfPlayer!),
      ],
    );
  }

  Widget _buildDropZone(BuildContext context, ClientManager manager, Game game) {
    return Positioned.fill(
      bottom: MediaQuery.of(context).size.height / 4,
      child: DragTarget<CardGame>(
        onAcceptWithDetails: (details) {
          droppedCard = details.data; // Questo è ancora stato locale, ok

          if (_isValidPutCard(context, manager, game, droppedCard!)) {
            // Server-authoritative: la carta viene rimossa alla ricezione di PLAYED_CARD
            PutCard putCardExecutable = PutCard(
              droppedCard!.seed,
              droppedCard!.value,
              manager.mySelfPlayer!.getNickname(),
            );
            Command command = Command(
              commandType: CommandType.PUT_CARD,
              executable: putCardExecutable,
              nickName: manager.mySelfPlayer!.getNickname(),
            );
            manager.sendCommand(command.toJson());
          }
        },
        builder: (BuildContext context, List<CardGame?> candidateData, List<dynamic> rejectedData) {
          return Center(
            child: Text(
              candidateData.isNotEmpty ? 'Drop here!' : '',
              style: TextStyle(color: candidateData.isNotEmpty ? Colors.red : Colors.white),
            ),
          );
        },
      ),
    );
  }

  // --- Metodi di logica/validazione ---

  bool _isValidPutCard(BuildContext context, ClientManager manager, Game game, CardGame card) {
    final me = manager.mySelfPlayer!;
    if (me.playerState != PlayerState.PUT) {
      showMessage('You cannot play now, wait for your turn!');
      return false;
    }
    final leader = game.playerOrder[0];
    if (leader.nickname == me.nickname) {
      return true;
    }
    if (!GameRules.isValidCard(leadCard: leader.playedCardNotifier.value, hand: me.handCards, card: card)) {
      showMessage('You must play a card of the same seed as the first played card!');
      return false;
    }
    return true;
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  bool checkIfValidBet(BuildContext context, ClientManager manager, Game game, int bet) {
    return GameRules.isValidBet(
      playerOrder: game.playerOrder,
      myNickname: manager.mySelfPlayer!.getNickname(),
      bet: bet,
      cardsInHand: game.getSet(),
    );
  }

}
