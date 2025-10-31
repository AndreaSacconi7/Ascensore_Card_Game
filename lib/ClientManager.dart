import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_socket/model/CardGame.dart';
import 'package:test_socket/pages/HomePage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

import 'AuthState.dart';
import 'command/Command.dart';
import 'command/CommandType.dart';
import 'command/LoginRequest.dart';
import 'command/PlayerInfoRequest.dart';
import 'message/BriscolaUpdate.dart';
import 'message/EndRoundUpdate.dart';
import 'message/EndSetUpdate.dart';
import 'message/ExecutableInClient.dart';
import 'message/HandUpdate.dart';
import 'message/LoginResponse.dart';
import 'message/PlayedCardUpdate.dart';
import 'message/PlayerInfoResponse.dart';
import 'message/PlayerStateUpdate.dart';
import 'message/SettedBetUpdate.dart';
import 'message/StartingGame.dart';
import 'message/TextMessage.dart';
import 'model/Game.dart';
import 'model/MySelfPlayer.dart';

// 1. Rendi il ClientManager un ChangeNotifier
class ClientManager extends ChangeNotifier {
  // 2. Rimuovi la logica della PageInterface e della Coda
  // PageInterface? currentPage;
  // final Queue<Message> _messageQueue = Queue<Message>();
  // final _condition = Condition();
  // bool _isRunning = false;

  late final WebSocketChannel channel;
  late final Stream _stream;

  // 3. Aggiungi qui lo STATO (i dati di gioco principali)
  final _storage = const FlutterSecureStorage();
  MySelfPlayer? mySelfPlayer;
  Game? game;
  bool isAuthenticated = false;
  AuthState authState = AuthState.unknown;
  String? authError;

  ClientManager(WebSocketChannel channel) {
    this.channel = channel;
    _stream = channel.stream.asBroadcastStream();

    // 4. Ascolto diretto. Il flusso dei messaggi è la nostra "coda".
    _stream.listen(_handleMessage);
    // _startProcessing(); // Non più necessario
  }

  // Il getter per mySelfPlayer (lo avevi già)
  MySelfPlayer? getMySelfPlayer() {
    return mySelfPlayer;
  }

  void sendCommand(dynamic jsonCommand) {
    print('Sending command to server: $jsonCommand');
    channel.sink.add(jsonCommand);
  }

  // 5. _handleMessage ora ESEGUE e NOTIFICA
  void _handleMessage(dynamic jsonMessage) {
    print('Message from server: $jsonMessage');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonMessage);
    final String stringMessageType = jsonMap['messageType'];

    // Identifica l'eseguibile (logica perfetta, la teniamo)
    final ExecutableInClient executable;

    if(stringMessageType == 'LOGIN_RESPONSE') {
      executable = LoginResponse.fromJson(jsonMap);
    }else if(stringMessageType == 'HAND_UPDATE') {
      executable = HandUpdate.fromJson(jsonMap);
    }else if(stringMessageType == 'BRISCOLA_UPDATE') {
      executable = BriscolaUpdate.fromJson(jsonMap);
    }else if(stringMessageType == 'STARTING_GAME') {
      executable = StartingGame.fromJson(jsonMap);
    }else if(stringMessageType == 'PLAYER_STATE_UPDATE') {
      executable = PlayerStateUpdate.fromJson(jsonMap);
    }else if(stringMessageType == 'SETTED_BET'){
      executable = SettedBetUpdate.fromJson(jsonMap);
    }else if(stringMessageType == 'PLAYED_CARD'){
      executable = PlayedCardUpdate.fromJson(jsonMap);
    }else if(stringMessageType == 'TEXT_MESSAGE') {
      executable = TextMessage.fromJson(jsonMap);
    } else if(stringMessageType == 'END_ROUND'){
      executable = EndRoundUpdate.fromJson(jsonMap);
    } else if(stringMessageType == 'END_SET'){
      executable = EndSetUpdate.fromJson(jsonMap);
    } else {
      print('Unknown message type: ${jsonMap['messageType']}');
      return;
    }

    // 6. ESEGUI SUL SERVIZIO STESSO
    // L'eseguibile ora modifica i dati DENTRO il ClientManager
    executable.execute(clientManager: this);

    // 7. NOTIFICA LA UI
    // Dopo che i dati sono stati aggiornati, avvisa tutti
    // i widget in ascolto (le tue pagine)
    notifyListeners();
  }


  /// Esegue il logout dell'utente
  Future<void> logout() async {
    // 1. Cancella il token salvato
    await _storage.delete(key: 'auth_token');

    // 2. Resetta lo stato interno del manager
    isAuthenticated = false;
    mySelfPlayer = null;
    game = null; // Resetta anche il gioco, se esiste

    // 3. Imposta lo stato su "non autenticato"
    authState = AuthState.unauthenticated;

    // 4. Notifica tutti i widget in ascolto (che causerà
    //    il ritorno alla LoginPage)
    notifyListeners();

    print("Logout eseguito, token cancellato.");
  }

  // --- AZIONI CHIAMATE DALLA UI ---
  /// Controlla se un token è già salvato all'avvio dell'app
  Future<void> checkLoginStatus() async {
    //TODO: rimuoverlo poi perche serve solo per debug
    await _storage.delete(key: 'auth_token');
    print("Token cancellato per debug");

    authState = AuthState.loading;
    notifyListeners();

    final token = await _storage.read(key: 'auth_token');

    print("Controllo token salvato: $token");

    if (token != null && token.isNotEmpty) {
      // Token trovato! In un'app reale, dovresti validarlo col server.
      // Per ora, assumiamo sia valido.

      print("Token valido trovato, autenticazione in corso...");
      // TODO: Invia il token al server per l'autenticazione automatica
      // String authMessage = jsonEncode({"event": "authenticate", "token": token});
      // channel.sink.add(authMessage);

      // Per ora, simuliamo un successo immediato
      isAuthenticated = true;
      authState = AuthState.authenticated;

    } else {
      // Nessun token, mostra la pagina di login
      isAuthenticated = false;
      authState = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Avvia il login con Apple
  void loginWithApple() {
    authState = AuthState.loading;
    notifyListeners();

    // TODO: Inserisci la logica dell'SDK 'sign_in_with_apple'
    // 1. Chiama l'SDK di Apple
    // 2. Invia le credenziali al tuo server
    // 3. Il server risponderà con 'LOGIN_RESPONSE'
    //    gestito da _handleMessage
  }

  /// Avvia il login con Google
  void loginWithGoogle() {
    authState = AuthState.loading;
    notifyListeners();

    // TODO: Inserisci la logica dell'SDK di Google
    // 1. Chiama l'SDK di Google per ottenere il token
    // 2. Quando hai il token, invialo al tuo server
    // 3. Il tuo server risponderà con un 'LOGIN_RESPONSE'
    //    che sarà gestito automaticamente da _handleMessage

    // Se fallisce, gestisci l'errore:
    // _authState = AuthState.error;
    // _authError = "Login con Google fallito.";
    // notifyListeners();
  }


  /// Avvia il login come ospite
  void loginAsGuest(String username) {
    if (username.isEmpty) {
      authState = AuthState.error;
      authError = "Per favore, inserisci uno username";
      notifyListeners();
      return;
    }

    authState = AuthState.loading;
    notifyListeners();

    // --- Invio del comando al server ---
    final password = "guest_password"; // Fittizia

    LoginRequest loginRequest = LoginRequest(username: username, password: password);
    Command command = Command(
      commandType: CommandType.LOGIN_COMMAND,
      executable: loginRequest,
      nickName: username,
    );

    sendCommand(command.toJson());
  }

  void handlePlayedCard(PlayedCardUpdate playedCardUpdate) {

    for(var p in game!.players){
      if(p.getNickname() == playedCardUpdate.nickname){
        p.setPlayedCard(playedCardUpdate.playedCard);
        break;
      }
    }
    // 4. "Grida nel megafono" per avvisare la UI!
    notifyListeners();
  }

  /// Pulisce eventuali messaggi di errore
  void clearAuthError() {
    authError = null;
    authState = AuthState.unauthenticated;
  }

  void handleBriscolaUpdate(BriscolaUpdate briscolaUpdate) {}

  void handleEndRoundUpdate(EndRoundUpdate endRoundUpdate) {}

  void handleEndSetUpdate(EndSetUpdate endSetUpdate) {}

  void handleHandUpdate(HandUpdate handUpdate) {}

  void handleLoginResponse(LoginResponse response){
    //debug
    print('Response of the server: ${response.isLogged}, ${response.nickname}');

    if (response.isLogged) {
      print('Welcome, ${response.nickname}');

      //TODO: salvare token reale ricevuto dal server
      final token = response.nickname;

      isAuthenticated = true;
      authState = AuthState.authenticated;
      mySelfPlayer = MySelfPlayer(response.nickname);

      _storage.write(key: 'auth_token', value: token);

      _fetchPlayerInfo(token);

    } else {
      print('Login failed');
      // FALLIMENTO!
      isAuthenticated = false;
      authState = AuthState.error;
      authError = "Login fallito. Prova un altro nome."; // Esempio
    }

    notifyListeners();
  }

  // NUOVO METODO PER RICHIEDERE I DATI DEL GIOCATORE
  void _fetchPlayerInfo(String token) {
    // Questa è la logica che prima era nel costruttore di MainMenuScreen
    print("Richiesta informazioni giocatore con il token...");
    PlayerInfoRequest executable = PlayerInfoRequest(token: token);
    Command command = Command(commandType: CommandType.PLAYER_INFO_REQUEST, executable: executable);
    sendCommand(command.toJson());

    // NOTA: Il tuo server ora risponderà con un messaggio (es. PLAYER_STATE_UPDATE o simile)
    // che sarà gestito normalmente da _handleMessage
    // (Ho commentato la logica perché non ho le classi PlayerInfoRequest, ecc,
    // ma tu devi DECOMMENTARLA)
  }

  void handlePlayerInfo(PlayerInfoResponse playerInfoResponse) {

    mySelfPlayer = MySelfPlayer(playerInfoResponse.nickname);
    notifyListeners();
  }

  void handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate) {}

  void handleSettedBet(SettedBetUpdate settedBetUpdate) {}

  void handleStartingGame(StartingGame startingGame) {}

  void handleTextMessage(TextMessage textMessage) {}


// ... altri metodi come loginWithGoogle, etc.
}

/*
// --- MODIFICHE AI TUOI EXECUTABLE ---

// Devi modificare la firma dei tuoi 'Executable'
abstract class ExecutableInClient {
  // Non riceve più 'PageInterface', ma 'ClientManager'
  void execute(ClientManager manager);
}

// Esempio con LoginResponse
class LoginResponse implements ExecutableInClient {
  final MySelfPlayer playerData; // Dati parsati dal JSON
  final String token;

  LoginResponse(this.playerData, this.token);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // ... parsa il JSON per estrarre i dati del player e il token
    return LoginResponse(
        MySelfPlayer.fromJson(json['playerData']),
        json['token']
    );
  }

  @override
  void execute(ClientManager manager) {
    // AGGIORNA LO STATO nel manager, non la UI
    manager.mySelfPlayer = playerData;
    manager.isAuthenticated = true;

    // Il token va salvato in flutter_secure_storage,
    // possiamo farlo qui o nel manager
    // final _storage = FlutterSecureStorage();
    // _storage.write(key: 'auth_token', value: token);

    print("LoginResponse eseguito, stato aggiornato.");
  }
}

// Esempio con HandUpdate
class HandUpdate implements ExecutableInClient {
  final List<CardGame> newHand;

  HandUpdate(this.newHand);

  factory HandUpdate.fromJson(Map<String, dynamic> json) {
    // ... parsa json['hand']
    return HandUpdate(/* lista di carte parsata */ []);
  }

  @override
  void execute(ClientManager manager) {
    // AGGIORNA LO STATO
    manager.hand = newHand;
    print("HandUpdate eseguito, mano aggiornata.");
  }
}

// E il tuo MySelfPlayer (classi di dati)
class MySelfPlayer {
  final String nickname;
  MySelfPlayer(this.nickname);

  factory MySelfPlayer.fromJson(Map<String, dynamic> json) {
    return MySelfPlayer(json['nickname']);
  }
}

class CardGame {}
*/