import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/command/Command.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/pages/PageInterface.dart';
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

  //dopo vanno popolate con i dati veri
  List<String> handCards = List.generate(10, (index) => 'Carta ${index + 1}');

  String briscola = 'Asso di Denari';

  List<String> playedCards = List.generate(4, (index) => 'Carta ${index + 1}');

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebSocket Demo')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Questa parte ora espande correttamente il GridView
            /*Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(8),
                children: [
                  StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      return Center(
                        child: Text(
                          snapshot.hasData ? '${snapshot.data}' : 'No data',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                  const PlayerWidget(name: "Playerr", avatarUrl: "ciao.png"),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onSubmitted: (text) => channel.sink.add(text),
                      decoration: InputDecoration(
                        labelText: 'Send message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const PlayerWidget(name: "PlayerDue", avatarUrl: "ciao.png"),
                  Container(color: Colors.grey.shade300), // per riempire lo spazio
                  Container(color: Colors.grey.shade300), // per riempire lo spazio
                  Container(color: Colors.grey.shade300), // per riempire lo spazio
                  Container(color: Colors.grey.shade300), // per riempire lo spazio

                  const PlayerWidget(
                    name: 'Player 1',
                    avatarUrl: 'https://example.com/avatar1.png',
                  ),
                ],
              ),
            ),


*/

            Row(
              children: [
                PlayerWidget(name: "Andrea", avatarUrl: "aa"),
                PlayerWidget(name: "Luca", avatarUrl: "aa"),
                PlayerWidget(name: "Paolo", avatarUrl: "aa")
              ],
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardWidget(cardName: playedCards[0]),     //carta in alto al centro
              ],
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardWidget(cardName: playedCards[1]),       //carta a sx
                CardWidget(cardName: briscola),           //briscola al centro
                CardWidget(cardName: playedCards[2]),     //carta a dx
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardWidget(cardName: playedCards[3]),       //carta in basso al centro
              ],
            ),


            // Carte in basso – visibile perché fuori dal GridView
          ],
        ),
      ),
      bottomNavigationBar: Container(
          height: 160,
          color: Colors.black12,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: handCards.map((card) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CardWidget(cardName: card),
                );
              }).toList(),
            ),
          ),
      ),
    );
  }

  @override
  handleLoginResponse(LoginResponse response) {
    // TODO: implement handleLoginResponse

  }
}