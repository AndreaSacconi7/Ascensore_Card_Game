import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/command/Command.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/message/StartingGame.dart';
import 'package:test_socket/model/Game.dart';
import 'package:test_socket/model/Player.dart';
import 'package:test_socket/pages/PageInterface.dart';
import 'package:test_socket/widgets/BetWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
            // Riga con la carta giocata in alto
            _buildTopCardRow(),
            // Riga centrale con le carte giocate dai giocatori e la briscola
            _buildMiddleRow(),
            // Riga in basso con scommesse e prese
            _buildBetAndTakenRow(),
          ],
        ),
      ),
      // Carte in basso
      bottomNavigationBar: _buildHandCardsBar(),
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

  Widget _buildBetAndTakenRow() {
    return const Row(
      children: [
        BetWidget(),
        TakenWidget(),
      ],
    );
  }

  Widget _buildHandCardsBar() {
    return Container(
      height: 160,
      color: Colors.black12,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.clientManager.mySelfPlayer?.handCards.isNotEmpty == true
              ? widget.clientManager.mySelfPlayer!.handCards
              .map((card) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CardWidget(card: card),
          ))
              .toList()
              : [Text('No cards in hand')],
        ),
      ),
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
      for(var playerNick in startingGame.connectedPlayers){
        var finded = false;
        for(var p in game.players){
          if(p.getNickname() == playerNick || playerNick == widget.clientManager.mySelfPlayer?.getNickname()){
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

}