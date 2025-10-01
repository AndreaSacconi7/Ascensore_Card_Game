import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/command/Command.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/LoginResponse.dart';
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


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: game.players.isNotEmpty ? game.players.map((player) {
                return PlayerWidget(
                  name: player.getNickname(),
                  avatarUrl: "default_avatar_url",
                );
              }).toList()
              : [Text('No players available yet')],
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                game.players.isNotEmpty && game.players[0].playedCard != null
                    ? CardWidget(card: game.players[0].playedCard!) // carta in alto al centro
                    : SizedBox.shrink(), // Widget di default nascosto
              ],
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                game.players.isNotEmpty && game.players[1].playedCard != null
                    ? CardWidget(card: game.players[1].playedCard!)   //carta a sx
                    : SizedBox.shrink(),
                game.players.isNotEmpty && game.briscola != null
                    ? CardWidget(card: game.briscola!)   //briscola al centro
                    : SizedBox.shrink(),
                game.players.isNotEmpty && game.players[2].playedCard != null
                    ? CardWidget(card: game.players[2].playedCard!)     //  carta a dx
                    : SizedBox.shrink(),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                game.players.isNotEmpty && game.players[3].playedCard != null
                    ? CardWidget(card: game.players[3].playedCard!)     //carta in basso al centro
                    : SizedBox.shrink(),
              ],
            ),

            const Row(
              children: [
                BetWidget(),
                TakenWidget(),
              ],
            ),
          ],
        ),
      ),
      // Carte in basso
      bottomNavigationBar: Container(
          height: 160,
          color: Colors.black12,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.clientManager.mySelfPlayer!.handCards.isNotEmpty ? widget.clientManager.mySelfPlayer!.handCards.map((card) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CardWidget(card: card),
                );
              }).toList()
              : [Text('No cards in hand')],
            ),
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

}