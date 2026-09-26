import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client_manager.dart';
import '../model/card_game.dart';
import '../model/game.dart';
import '../model/game_rules.dart';
import '../model/my_self_player.dart';
import '../model/player_state.dart';
import '../model/set_result_animation_state.dart';
import '../ui/components.dart';
import '../ui/game_widgets.dart';
import '../ui/theme.dart';
import 'game/bet_sheet.dart';
import 'game/game_top_bar.dart';
import 'game/hand_fan.dart';
import 'game/opponent_tile.dart';
import 'game/seating.dart';
import 'game/set_result_toast.dart';
import 'game/status_pill.dart';
import 'game/table_view.dart';
import 'game/waiting_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  ClientManager? _manager;
  bool _betSheetOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final manager = context.read<ClientManager>();
    if (manager != _manager) {
      _manager?.removeListener(_onManagerChanged);
      _manager = manager..addListener(_onManagerChanged);
      // The player may already be betting, e.g. right after a reconnection
      WidgetsBinding.instance.addPostFrameCallback((_) => _onManagerChanged());
    }
  }

  @override
  void dispose() {
    _manager?.removeListener(_onManagerChanged);
    super.dispose();
  }

  // The bet sheet opens when it is your turn to bet and closes if the turn moves on without you
  void _onManagerChanged() {
    if (!mounted) return;
    final manager = _manager!;
    final me = manager.mySelfPlayer;
    final game = manager.game;
    if (me == null || game == null) return;

    if (me.playerState == PlayerState.BET && !_betSheetOpen) {
      _betSheetOpen = true;
      showBetSheet(context, game: game, me: me).then((bet) {
        _betSheetOpen = false;
        if (bet != null) manager.setBet(bet);
      });
    } else if (me.playerState != PlayerState.BET && _betSheetOpen) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, manager, _) {
        final game = manager.game;
        final me = manager.mySelfPlayer;
        if (game == null || me == null) {
          return const WaitingView();
        }
        return Stack(
          children: [
            SafeArea(child: ContentWidth(maxWidth: 720, child: _Table(manager: manager, game: game, me: me))),
            if (manager.lastSetResult != SetResultAnimationState.none)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SetResultToast(
                      won: manager.lastSetResult == SetResultAnimationState.win,
                      delta: manager.lastSetDelta,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Table extends StatelessWidget {
  final ClientManager manager;
  final Game game;
  final MySelfPlayer me;

  const _Table({required this.manager, required this.game, required this.me});

  bool get _canPlay => me.playerState == PlayerState.PUT;

  // Mirrors the server rule so the hand can dim cards you may not play
  bool _isPlayable(CardGame card) {
    final leader = game.playerOrder.isEmpty ? null : game.playerOrder.first;
    final leadCard = leader == me ? null : leader?.playedCard;
    return GameRules.isValidCard(leadCard: leadCard, hand: me.handCards, card: card);
  }

  void _explainBlocked(BuildContext context) {
    final lead = game.playerOrder.first.playedCard;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(lead == null ? 'Non puoi giocare questa carta.' : 'Devi rispondere al seme della prima carta.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final opponents = opponentsFrom(game, me);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: GameTopBar(game: game),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: opponents.length == 1
              ? SizedBox(width: 160, child: OpponentTile(player: opponents.first))
              : Row(
                  children: [
                    for (var i = 0; i < opponents.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: OpponentTile(player: opponents[i])),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TableView(
              game: game,
              me: me,
              opponents: opponents,
              canDrop: (card) => _canPlay && _isPlayable(card),
              onDrop: manager.putCard,
            ),
          ),
        ),
        const SizedBox(height: 12),
        StatusPill(game: game, me: me),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            radius: AppRadius.medium,
            child: Row(
              children: [
                PlayerAvatar(nickname: me.nickname, size: 34, active: isOnTurn(me)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tu', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        me.nickname,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PlayerStats(player: me),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: HandFan(
            cards: me.handCards,
            canPlay: _canPlay,
            isPlayable: _isPlayable,
            onPlay: manager.putCard,
            onBlocked: (_) => _explainBlocked(context),
          ),
        ),
      ],
    );
  }
}
