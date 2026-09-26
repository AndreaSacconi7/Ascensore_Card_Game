import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ascensore_client/model/player_state.dart';
import 'package:ascensore_client/model/set_result_animation_state.dart';

import '../client_manager.dart';
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
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 900.0;

  ClientManager? _clientManager;

  // Reacting to changes (rather than building from state) for things that happen once:
  // opening the bet dialog, showing a notice, starting the set result animation
  bool _betDialogOpen = false;
  SetResultAnimationState _uiAnimationState = SetResultAnimationState.none;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final manager = context.read<ClientManager>();
    if (manager != _clientManager) {
      _clientManager?.removeListener(_handleClientChanges);
      _clientManager = manager;
      manager.addListener(_handleClientChanges);
      // The player may already be betting, e.g. right after a reconnection
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleClientChanges());
    }
  }

  @override
  void dispose() {
    _clientManager?.removeListener(_handleClientChanges);
    super.dispose();
  }

  void _handleClientChanges() {
    if (!mounted) return;
    final manager = _clientManager!;
    final me = manager.mySelfPlayer;
    final game = manager.game;

    if (me != null && game != null) {
      if (me.playerState == PlayerState.BET && !_betDialogOpen) {
        _showBetOverlay(manager, game);
      } else if (me.playerState != PlayerState.BET && _betDialogOpen) {
        // The turn moved on without us (reconnection, match over): close the dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    final notice = manager.consumeNotice();
    if (notice != null) {
      showMessage(notice);
    }

    if (manager.lastSetResult != _uiAnimationState) {
      setState(() => _uiAnimationState = manager.lastSetResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, manager, child) {
        final game = manager.game;
        final me = manager.mySelfPlayer;

        if (game == null || me == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('In attesa degli altri giocatori…'),
                ],
              ),
            ),
          );
        }

        final isDesktop = MediaQuery.of(context).size.width >= desktopBreakpoint;

        return Scaffold(
          body: Stack(
            children: [
              _buildDropZone(context, manager, game),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    _buildPlayersRow(context, manager, game),
                    const Spacer(flex: 4),
                    _buildTopCardRow(manager, game),
                    const Spacer(flex: 3),
                    _buildMiddleRow(manager, game),
                    const Spacer(flex: 3),
                    if (isDesktop)
                      _buildMySelfPlayedCardRowDesktop(manager)
                    else ...[
                      _buildMySelfPlayedCardRow(manager),
                      const Spacer(flex: 3),
                      MySelfBetTakenScoreWidget(player: me),
                    ],
                    if (isDesktop) const Spacer(flex: 3),
                    const Expanded(
                      flex: 15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [HandCards()],
                      ),
                    ),
                  ],
                ),
              ),
              if (_uiAnimationState != SetResultAnimationState.none)
                Positioned.fill(
                  child: Center(
                    child: SetResultAnimation(
                      isWin: _uiAnimationState == SetResultAnimationState.win,
                      onComplete: () {},
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayersRow(BuildContext context, ClientManager manager, Game game) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double spacing = (screenWidth > tabletBreakpoint) ? 100.0 : 8.0;
    final opponents = _getOpponents(manager, game);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: 8.0,
      children: opponents
          .map((player) => PlayerWidget(name: player.nickname, avatarUrl: "default_avatar_url", player: player))
          .toList(),
    );
  }

  List<Player> _getOpponents(ClientManager manager, Game game) =>
      game.players.where((p) => p != manager.mySelfPlayer).toList();

  // The first opponent's card sits at the top, the others left and right of the briscola
  Widget _buildTopCardRow(ClientManager manager, Game game) {
    final opponents = _getOpponents(manager, game);
    if (opponents.isEmpty || opponents[0].playedCard == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlayedCardWidget(playedCardNotifier: opponents[0].playedCardNotifier)],
    );
  }

  Widget _buildMiddleRow(ClientManager manager, Game game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOpponentCard(manager, game, 1),
        const SizedBox(width: 60),
        game.briscola != null ? CardWidget(card: game.briscola!) : const SizedBox.shrink(),
        const SizedBox(width: 60),
        _buildOpponentCard(manager, game, 2),
      ],
    );
  }

  Widget _buildOpponentCard(ClientManager manager, Game game, int opponentIndex) {
    final opponents = _getOpponents(manager, game);
    if (opponents.length <= opponentIndex || opponents[opponentIndex].playedCard == null) {
      return const SizedBox.shrink();
    }
    return PlayedCardWidget(playedCardNotifier: opponents[opponentIndex].playedCardNotifier);
  }

  Widget _buildMySelfPlayedCardRow(ClientManager manager) {
    final me = manager.mySelfPlayer!;
    if (me.playedCard == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlayedCardWidget(playedCardNotifier: me.playedCardNotifier)],
    );
  }

  Widget _buildMySelfPlayedCardRowDesktop(ClientManager manager) {
    final me = manager.mySelfPlayer!;
    return Stack(
      children: [
        Center(
          child: me.playedCard != null
              ? PlayedCardWidget(playedCardNotifier: me.playedCardNotifier)
              : const SizedBox.shrink(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: MySelfBetTakenScoreWidget(player: me),
        ),
      ],
    );
  }

  void _showBetOverlay(ClientManager manager, Game game) {
    _betDialogOpen = true;
    double sliderValue = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                      max: game.set.toDouble(),
                      divisions: game.set,
                      label: sliderValue.toStringAsFixed(0),
                      onChanged: (double value) => setState(() => sliderValue = value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final bet = sliderValue.toInt();
                        if (_isValidBet(manager, game, bet)) {
                          Navigator.of(dialogContext).pop();
                          manager.setBet(bet);
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
    ).whenComplete(() => _betDialogOpen = false);
  }

  Widget _buildDropZone(BuildContext context, ClientManager manager, Game game) {
    return Positioned.fill(
      bottom: MediaQuery.of(context).size.height / 4,
      child: DragTarget<CardGame>(
        onAcceptWithDetails: (details) {
          if (_isValidPutCard(manager, game, details.data)) {
            manager.putCard(details.data);
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

  bool _isValidPutCard(ClientManager manager, Game game, CardGame card) {
    final me = manager.mySelfPlayer!;
    if (me.playerState != PlayerState.PUT) {
      showMessage('You cannot play now, wait for your turn!');
      return false;
    }
    final leader = game.playerOrder.first;
    if (leader == me) {
      return true;
    }
    if (!GameRules.isValidCard(leadCard: leader.playedCard, hand: me.handCards, card: card)) {
      showMessage('You must play a card of the same seed as the first played card!');
      return false;
    }
    return true;
  }

  bool _isValidBet(ClientManager manager, Game game, int bet) {
    return GameRules.isValidBet(
      playerOrder: game.playerOrder,
      myNickname: manager.mySelfPlayer!.nickname,
      bet: bet,
      cardsInHand: game.set,
    );
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
