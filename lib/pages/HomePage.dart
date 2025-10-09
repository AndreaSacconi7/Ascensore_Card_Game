import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/command/Command.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/message/PlayerStateUpdate.dart';
import 'package:test_socket/message/StartingGame.dart';
import 'package:test_socket/message/TextMessage.dart';
import 'package:test_socket/model/Game.dart';
import 'package:test_socket/model/Player.dart';
import 'package:test_socket/pages/PageInterface.dart';
import 'package:test_socket/widgets/BetWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/CardGame.dart';
import '../model/PlayerState.dart';
import '../widgets/CardWidget.dart';
import '../widgets/PlayerWidget.dart';

class HomePage extends StatefulWidget {

  ClientManager clientManager;

  HomePage({super.key, required this.clientManager});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements PageInterface {

  //dopo vanno cancellate perchè si usano quelle in game
  /*List<String> handCards = List.generate(10, (index) => 'Carta ${index + 1}');
  String briscola = 'Asso di Denari';
  List<String> playedCards = List.generate(4, (index) => 'Carta ${index + 1}');*/

  Game game = Game();

  @override
  void initState() {
    super.initState();
    widget.clientManager.setCurrentPage(this);
  }

  void _handleMessage(dynamic message) {
    // Gestisci i messaggi in arrivo dal server WebSocket
    print('Message from server: $message');
    // Puoi aggiornare lo stato del widget in base ai messaggi ricevuti
  }

  void _sendCommand(Command command) {
    widget.clientManager.sendCommand(command);
  }

  @override
  handleLoginResponse(LoginResponse response) {

    if(response.isLogged) {
      print('New user logged in, ${response.nickname}');
      setState(() {
        Player newPlayer = Player(response.nickname);
        game.players.add(newPlayer);
      });
    } else {
      print('Login failed for new client ${response.nickname}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebSocket Demo')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Riga in alto con i giocatori
            _buildPlayersRow(),

            SizedBox(height: 20),

            // Riga con la carta giocata in alto
            _buildTopCardRow(),

            SizedBox(height: 20),

            // Riga centrale con le carte giocate dai giocatori e la briscola
            _buildMiddleRow(),

            SizedBox(height: 20),

            _buildDropZone(),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBetAndTakenRow(),
                   SizedBox(height: 20),
                  _buildHandCardsBar(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Carte in basso
      //bottomNavigationBar: _buildHandCardsBar(),
    );
  }

  Widget _buildPlayersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: game.players.isNotEmpty
          ? game.players.map((player) => PlayerWidget(
        name: player.getNickname(),
        avatarUrl: "default_avatar_url",
      )).toList()
          : [Text('No players available yet')],
    );
  }

  Widget _buildTopCardRow() {
    final topPlayer = game.players.isNotEmpty ? game.players[0] : null;
    return topPlayer?.playedCard != null
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CardWidget(card: topPlayer!.playedCard!)],
    )
        : SizedBox.shrink();
  }

  Widget _buildMiddleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayerCard(1),
        _buildBriscolaCard(),
        _buildPlayerCard(2),
      ],
    );
  }

  Widget _buildPlayerCard(int playerIndex) {
    final player = game.players.length > playerIndex ? game.players[playerIndex] : null;
    return player?.playedCard != null
        ? CardWidget(card: player!.playedCard!)
        : SizedBox.shrink();
  }

  Widget _buildBriscolaCard() {
    return game.briscola != null
        ? CardWidget(card: game.briscola!)
        : SizedBox.shrink();
  }

  void _showBetOverlay(BuildContext context) {
    double sliderValue = 0;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the overlay by clicking outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Set your bet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Slider(
                      value: sliderValue,
                      min: 0,
                      max: game.getSet().toDouble(),
                      divisions: game.getSet(),
                      label: sliderValue.toStringAsFixed(0),
                      onChanged: (double value) {
                        setState(() {
                          sliderValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the overlay
                        widget.clientManager.mySelfPlayer?.setBet(sliderValue.toInt());
                        print('Bet confirmed: ${widget.clientManager.mySelfPlayer?.getBet()}');
                        //TODO: invio command con BET al server
                      },
                      child: Text('Confirm'),
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

  Widget _buildBetAndTakenRow() {
    return const Row(
      children: [
        BetWidget(),
        TakenWidget(),
      ],
    );
  }

  Widget _buildHandCardsBar() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final handCards = widget.clientManager.mySelfPlayer?.handCards ?? [];
        final cardWidth = 100.0;
        final maxVisibleWidth = constraints.maxWidth;
        final overlap = handCards.length * cardWidth > maxVisibleWidth
            ? (handCards.length * cardWidth - maxVisibleWidth) / handCards.length
            : 0.0;

        return Container(
          height: 160,
          color: Colors.black12,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: handCards.isNotEmpty
                ? List.generate(handCards.length, (index) {
              return Transform.translate(
                offset: Offset(-index * overlap, 0),
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 4.0),
                  child: Draggable<CardGame>(
                    data: handCards[index], // Passa i dati della carta
                    feedback: Material(
                      color: Colors.transparent,
                      child: CardWidget(card: handCards[index]),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: CardWidget(card: handCards[index]),
                    ),
                    child: CardWidget(card: handCards[index]),
                  ),
                ),
              );
            })
                : [const Text('No cards in hand')],
          ),
        );
      },
    );
  }

  Widget _buildDropZone() {
    return DragTarget<CardGame>(
      onAcceptWithDetails: (card) {
        //print('Card dropped: ${card.getImagePath()}');
        // Gestisci il comportamento quando una carta viene rilasciata
      },
      builder: (BuildContext context, List<CardGame?> candidateData, List<dynamic> rejectedData) {
        return Container(
          height: 120,
          width: 120,
          color: Colors.green.withOpacity(0.5),
          child: Center(
            child: Text(
              candidateData.isNotEmpty ? 'Drop here!' : 'Drop Zone',
              style: candidateData.isNotEmpty ? TextStyle(color: Colors.red) : TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  handleHandUpdate(HandUpdate handUpdate) {

    setState(() {
      widget.clientManager.mySelfPlayer?.setHandCards(handUpdate.handCards);
    });
  }

  @override
  handleBriscolaUpdate(BriscolaUpdate briscolaUpdate) {

    setState(() {
      game.setBriscola(briscolaUpdate.briscolaCard);
    });
  }

  @override
  handleStartingGame(StartingGame startingGame) {

    setState(() {
      //aggiungo me stesso alla lista di giocatori nel game
      game.addPlayer(widget.clientManager.mySelfPlayer!);

      //aggiungo altri player alla lista di giocatori nel game
      for(var playerNick in startingGame.connectedPlayers){
        var finded = false;
        for(var p in game.players){
          if(p.getNickname() == playerNick){
            finded = true;
            break;
          }
        }
        if(!finded){
          game.addPlayer(Player(playerNick));
        }
      }
    });
  }

  @override
  handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate) {

    setState(() {
      for(var p in game.players){
        if(p.getNickname() == playerStateUpdate.nickname){
          p.setPlayerState(playerStateUpdate.playerState);

          // Controlla se il giocatore è mySelfPlayer e lo stato è BET
          if (p == widget.clientManager.mySelfPlayer && p.playerState == PlayerState.BET) {
            _showBetOverlay(context);       // Mostra l'overlay per la scommessa
          }
          break;
        }
      }
    });
  }

  @override
  handleTextMessage(TextMessage textMessage) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(textMessage.text)),
    );
  }

}