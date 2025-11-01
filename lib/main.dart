import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_socket/pages/LoginPage.dart';
import 'package:test_socket/pages/MainMenuScreen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'AppWrapper.dart';
import 'ClientManager.dart';
import 'pages/LoginPageOld.dart';

void main() {
  final channel = WebSocketChannel.connect(Uri.parse(kIsWeb ? 'ws://localhost:8080/ws' : 'ws://10.0.2.2:8080/ws'));
  //final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080/ws'));

  // 2. Crea l'istanza del tuo ClientManager (che è un ChangeNotifier)
  final clientManager = ClientManager(channel);

  runApp(
    ChangeNotifierProvider(
      create: (context) => clientManager,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  //final String ip = kIsWeb ? 'ws://localhost:8080/ws' : 'ws://10.0.2.2:8080/ws';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascensore Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          background: const Color(0xff1f2023),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      //home: LoginPage(clientManager: clientManager),
      home: AppWrapper(),
    );
  }
}
