import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../components/CardWidget.dart';
import '../components/PlayerWidget.dart';

class HomePage extends StatelessWidget {
  final WebSocketChannel channel;

  HomePage({required this.channel});

  final List<String> cards = List.generate(10, (index) => 'Carta ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebSocket Demo')),
      body: SafeArea(
        child: Column(
          children: [
            // Questa parte ora espande correttamente il GridView
            Expanded(
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

            // Carte in basso – visibile perché fuori dal GridView
            Container(
              height: 160,
              color: Colors.black12,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: cards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CardWidget(cardName: card),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}