import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_socket/AppScreenState.dart';
import 'package:test_socket/message/EndGame.dart';
import 'package:test_socket/message/InfoAfterReconnection.dart';
import 'package:test_socket/message/JoinGameResponse.dart';
import 'package:test_socket/message/PlayerExitGame.dart';
import 'package:test_socket/model/CardGame.dart';
import 'package:test_socket/model/SetResultAnimationState.dart';
import 'package:test_socket/model/Seed.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

import 'AuthenticationState.dart';
import 'command/Command.dart';
import 'command/CommandType.dart';
import 'command/LoginRequest.dart';
import 'command/Logout.dart';
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
import 'model/Player.dart';
import 'model/PlayerState.dart';

// 1. Rendi il ClientManager un ChangeNotifier
class ClientManager extends ChangeNotifier {
  // 2. Rimuovi la logica della PageInterface e della Coda
  // PageInterface? currentPage;
  // final Queue<Message> _messageQueue = Queue<Message>();
  // final _condition = Condition();
  // bool _isRunning = false;

  WebSocketChannel? channel;
  StreamSubscription? _stream;

  // 3. Aggiungi qui lo STATO (i dati di gioco principali)
  final _storage = const FlutterSecureStorage();
  MySelfPlayer? mySelfPlayer;
  Game? game;
  bool isAuthenticated = false;
  AuthenticationState authState = AuthenticationState.unknown;
  String? authError;
  AppScreenState currentScreen = AppScreenState.login;
  bool calculatingScores = false;

  SetResultAnimationState lastSetResult = SetResultAnimationState.none;

  ClientManager() {
    //this.channel = channel;
    //_stream = channel.stream.asBroadcastStream();

    // 4. Ascolto diretto. Il flusso dei messaggi è la nostra "coda".
    //_stream.listen(_handleMessage);
    // _startProcessing(); // Non più necessario
  }

  void setCurrentScreen(AppScreenState newScreen) {
    currentScreen = newScreen;
    notifyListeners();
  }

  // Il getter per mySelfPlayer (lo avevi già)
  MySelfPlayer? getMySelfPlayer() {
    return mySelfPlayer;
  }

  void sendCommand(dynamic jsonCommand) {
    log('Sending command to server: $jsonCommand');

    channel!.sink.add(jsonCommand);
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
    }else if(stringMessageType == 'PLAYER_INFO_RESPONSE') {
      executable = PlayerInfoResponse.fromJson(jsonMap);
    }else if(stringMessageType == 'JOIN_GAME_RESPONSE'){
      executable = JoinGameResponse.fromJson(jsonMap);
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
    } else if(stringMessageType == 'END_GAME'){
      executable = EndGame.fromJson(jsonMap);
    } else if(stringMessageType == 'PLAYER_EXIT_GAME') {
      executable = PlayerExitGame.fromJson(jsonMap);
    } else if(stringMessageType == 'INFO_AFTER_RECONNECTION') {
      executable = InfoAfterReconnection.fromJson(jsonMap);
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

  // Metodo per connettersi (chiamato al Login o signUp)
  void connect() {
    if (channel != null) return; // Già connesso

    try {
      channel = WebSocketChannel.connect(Uri.parse(kIsWeb ? 'ws://localhost:8080/ws' : 'ws://10.0.2.2:8080/ws'));

      // Mettiamoci in ascolto
      _stream = channel!.stream.listen(
            (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print("Errore Socket: $error");
          logOut(); // Disconnetti in caso di errore
        },
        onDone: () {
          print("Socket chiuso dal server");
          logOut(); // Pulisci tutto se il server chiude
        },
      );
    } catch (e) {
      print("Impossibile connettersi: $e");
      //isConnected = false;
      notifyListeners();
    }
  }


  // Dentro ClientManager.dart
  Future<void> logOut() async {
    // 1. Dillo a Supabase (cancella il token locale)
    await Supabase.instance.client.auth.signOut();

    // 2. Chiudi la connessione col server Java (importante!)
    Logout logout = Logout();
    Command command = Command(
      commandType: CommandType.LOGOUT,
      executable: logout,
    );
    sendCommand(command.toJson());

    await _stream?.cancel(); // Smetti di ascoltare
    _stream = null;

    channel?.sink.close(); // Chiudi il socket
    channel = null;        // Resetta la variabile per il prossimo login

    //resetto lo stato del client manager
    mySelfPlayer = null;
    game = null;
    lastSetResult = SetResultAnimationState.none;

    // 3. Aggiorna lo stato della UI
    authState = AuthenticationState.unauthenticated;
    authError = null;
    isAuthenticated = false;
    currentScreen = AppScreenState.login;
    notifyListeners();

    print("Logout effettuato. Token cancellato.");
  }

  // --- AZIONI CHIAMATE DALLA UI ---
  /// Controlla se un token è già salvato all'avvio dell'app
  Future<void> checkLoginStatus() async {

    // 1. RIMUOVI LA CANCELLAZIONE DEBUG!
    // Se lasci questo, l'utente dovrà fare login ogni volta che apre l'app!
    // await _storage.delete(key: 'auth_token');

    authState = AuthenticationState.loading;
    notifyListeners();

    // 2. Chiedi a Supabase: "Abbiamo una sessione valida salvata?"
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {

      if(session.isExpired){
        try {
          // Forza il refresh del token
          final response = await Supabase.instance.client.auth.refreshSession();
          final freshToken = response.session?.accessToken;

          if (freshToken != null) {
            print("Token rinnovato con successo!");
            _fetchPlayerInfoWithExistingToken(freshToken);
          } else {
            print("Impossibile rinnovare. Logout forzato.");
            logOut();
          }
        } catch (e) {
          print("Errore durante il refresh del token: ${e.toString()}");
          logOut();
        }
      }else{
        //Token ancora valido, procedo normalmente
        // Trovato! Supabase ha gestito il refresh se necessario.
        String validToken = session.accessToken;
        print("Sessione Supabase trovata. Token: ${validToken.substring(0, 10)}...");

        // 3. Autenticazione col Backend (WebSocket)
        // Qui inviamo il comando che il tuo backend Java si aspetta
        _fetchPlayerInfoWithExistingToken(validToken);
      }

      /*isAuthenticated = true;
      authState = AuthenticationState.authenticated;
      currentScreen = AppScreenState.mainMenu;*/

    } else {
      // Nessuna sessione salvata, l'utente deve fare il login manuale
      print("Nessuna sessione trovata.");
      isAuthenticated = false;
      authState = AuthenticationState.unauthenticated;
      currentScreen = AppScreenState.login;
    }

    notifyListeners();
  }

  /// Avvia il login con Apple
  void loginWithApple() {
    authState = AuthenticationState.loading;
    notifyListeners();

    // TODO: Inserisci la logica dell'SDK 'sign_in_with_apple'
    // 1. Chiama l'SDK di Apple
    // 2. Invia le credenziali al tuo server
    // 3. Il server risponderà con 'LOGIN_RESPONSE'
    //    gestito da _handleMessage
  }

  /// Avvia il login con Google
  void loginWithGoogle() {
    authState = AuthenticationState.loading;
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
      authState = AuthenticationState.error;
      authError = "Per favore, inserisci uno username";
      currentScreen = AppScreenState.login;
      notifyListeners();
      return;
    }

    authState = AuthenticationState.loading;
    notifyListeners();

    // --- Invio del comando al server ---
    final password = "guest_password"; // Fittizia

    //TODO: modificare questo command e inviare invece un fetchPlayerInfo con nickname voluto. però gestire risposta che deve sostiuire quella che ora è la risposta del login in caso il nickname non vada bene
    LoginRequest loginRequest = LoginRequest(username: username, password: password);
    Command command = Command(
      commandType: CommandType.LOGIN_COMMAND,
      executable: loginRequest,
      nickName: username,
    );

    sendCommand(command.toJson());
  }

  //NEW LOGIN METHOD:
  Future<void> loginWithEmail(String email, String password) async {
    authState = AuthenticationState.loading;
    notifyListeners();
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password
      );
      if (res.session != null) {
        _fetchPlayerInfoFirstTime(res.session!.accessToken, email);
      }
    } catch (e) {
      authError = "Login fallito: ${e.toString()}";
      authState = AuthenticationState.error;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    authState = AuthenticationState.loading;
    notifyListeners();
    try {
      final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password
      );
      // Nota: Supabase di default richiede conferma email.
      // Se disattivata, fa login automatico.
      if (res.session != null) {
        _fetchPlayerInfoFirstTime(res.session!.accessToken, email);
      } else {
        //NON ATTIVA QUESTA COSA
        authError = "Controlla la tua email per confermare l'iscrizione!";
        authState = AuthenticationState.error; // O uno stato 'waiting_confirmation'
        notifyListeners();
      }
    } catch (e) {
      authError = "Registrazione fallita: ${e.toString()}";
      authState = AuthenticationState.error;
      notifyListeners();
    }
  }

  void _fetchPlayerInfoFirstTime(String token, String nickname){

    connect();

    PlayerInfoRequest playerInfoRequest = PlayerInfoRequest(token: token, nickname: nickname);
    Command command = Command(
      commandType: CommandType.PLAYER_INFO_REQUEST,
      executable: playerInfoRequest,
      nickName: nickname,
    );

    sendCommand(command.toJson());
  }

  void _fetchPlayerInfoWithExistingToken(String token){

    connect();

    PlayerInfoRequest playerInfoRequest = PlayerInfoRequest(token: token, nickname: "fake_nickname");
    Command command = Command(
      commandType: CommandType.PLAYER_INFO_REQUEST,
      executable: playerInfoRequest,
      nickName: "fake_nickname",        //tanto sarà il server a identificare il giocatore dal token, questo è solo un placeholder
    );

    sendCommand(command.toJson());
  }

  void handlePlayedCard(PlayedCardUpdate playedCardUpdate) {

    for(var p in game!.players){
      if(p.getNickname() == playedCardUpdate.nickname){
        p.setPlayedCard(playedCardUpdate.playedCard);

        if(playedCardUpdate.nickname == mySelfPlayer!.getNickname()){
          //rimuovo la carta giocata dalla mano del giocatore
          mySelfPlayer!.removeCardFromHand(playedCardUpdate.playedCard);
        }
        break;
      }
    }
  }

  /// Pulisce eventuali messaggi di errore
  void clearAuthError() {
    authError = null;
    authState = AuthenticationState.unauthenticated;
  }

  void handleBriscolaUpdate(BriscolaUpdate briscolaUpdate) {

    game?.setBriscola(briscolaUpdate.briscolaCard);
  }

  void handleEndRoundUpdate(EndRoundUpdate endRoundUpdate) {

    List<Player> newPlayerOrder = [];
    for(String nickname in endRoundUpdate.nextPlayerOrderAndTaken.keys){
      for(Player p in game!.players){
        if(p.getNickname() == nickname){
          p.setRoundsWon(endRoundUpdate.nextPlayerOrderAndTaken[nickname]!);
          newPlayerOrder.add(p);
          break;
        }
      }
    }

    game!.setPlayerOrder(newPlayerOrder);

    game!.setSet(endRoundUpdate.nextRoundNumber);

    Future.delayed(const Duration(seconds: 3), () {
      // Dopo 3 secondi, chiama il metodo di pulizia
      _clearBoardForNextRound();
    });
  }

  void handleEndSetUpdate(EndSetUpdate endSetUpdate) {

    List<Player> newPlayerOrder = [];

    for(String nickname in endSetUpdate.nextPlayerOrderAndScore.keys){
      for(Player p in game!.players){
        if(p.getNickname() == nickname){
          if(p.getNickname() == mySelfPlayer!.getNickname()){
            int oldScore = mySelfPlayer!.getScore();
            int newScore = endSetUpdate.nextPlayerOrderAndScore[nickname]!;

            // Se il punteggio è aumentato, ho vinto io
            if (newScore > oldScore) {
              lastSetResult = SetResultAnimationState.win;
            } else {
              // Se il punteggio è uguale, ha vinto qualcun altro
              lastSetResult = SetResultAnimationState.loss;
            }
          }
          p.setScore(endSetUpdate.nextPlayerOrderAndScore[nickname]!);
          newPlayerOrder.add(p);
          break;
        }
      }
    }

    game!.setPlayerOrder(newPlayerOrder);

    game!.setSet(endSetUpdate.nextSetNumber);

    calculatingScores = true;

    Future.delayed(const Duration(seconds: 3), () {
      // Dopo 3 secondi, chiama il metodo di pulizia
      _clearBoardForNextSet();
      calculatingScores = false;
      //resetto il risultato dell'ultimo set
      lastSetResult = SetResultAnimationState.none;
    });
  }

  void _clearBoardForNextRound(){
    for(var p in game!.players){
      p.setPlayedCard(new CardGame(Seed.VOID, 0));
    }
    notifyListeners();
  }

  void _clearBoardForNextSet(){
    for(var p in game!.players){
      p.setPlayedCard(new CardGame(Seed.VOID, 0));
      p.setRoundsWon(0);
      p.setBet(0);
    }
    notifyListeners();
  }

  void handleHandUpdate(HandUpdate handUpdate) {

    mySelfPlayer?.setHandCards(handUpdate.handCards);
  }

  /*void handleLoginResponse(LoginResponse response){
    //debug
    print('Response of the server: ${response.isLogged}, ${response.nickname}');

    if (response.isLogged) {
      print('Welcome, ${response.nickname}');

      //TODO: salvare token reale ricevuto dal server
      final token = response.nickname;

      isAuthenticated = true;
      authState = AuthenticationState.authenticated;
      currentScreen = AppScreenState.mainMenu;

      //mySelfPlayer = MySelfPlayer(response.nickname);

      _storage.write(key: 'auth_token', value: token);

      //_fetchPlayerInfo(token);

    } else {
      print('Login failed');
      // FALLIMENTO!
      isAuthenticated = false;
      authState = AuthenticationState.error;
      authError = "Login fallito. Prova un altro nome."; // Esempio
    }

  }*/

  // NUOVO METODO PER RICHIEDERE I DATI DEL GIOCATORE
  void _fetchPlayerInfo(String token) {
    // Questa è la logica che prima era nel costruttore di MainMenuScreen
    print("Richiesta informazioni giocatore con il token...");
    PlayerInfoRequest executable = PlayerInfoRequest(token: token, nickname: "fake_nickname");
    Command command = Command(commandType: CommandType.PLAYER_INFO_REQUEST, executable: executable);
    sendCommand(command.toJson());

    // NOTA: Il tuo server ora risponderà con un messaggio (es. PLAYER_STATE_UPDATE o simile)
    // che sarà gestito normalmente da _handleMessage
    // (Ho commentato la logica perché non ho le classi PlayerInfoRequest, ecc,
    // ma tu devi DECOMMENTARLA)
  }

  void handlePlayerInfo(PlayerInfoResponse playerInfoResponse) {

    if (playerInfoResponse.isLogged) {
      print('Welcome, ${playerInfoResponse.nickname}');

      //TODO: salvare token reale ricevuto dal server
      final token = playerInfoResponse.nickname;

      isAuthenticated = true;
      authState = AuthenticationState.authenticated;
      currentScreen = AppScreenState.mainMenu;

      mySelfPlayer = MySelfPlayer(playerInfoResponse.nickname);

      //mySelfPlayer = MySelfPlayer(response.nickname);

      //_storage.write(key: 'auth_token', value: token);

      //_fetchPlayerInfo(token);

    } else {
      print('Login failed');
      // FALLIMENTO!
      isAuthenticated = false;
      authState = AuthenticationState.error;
      authError = "Login fallito. Prova un altro nome."; // Esempio
    }
  }

  void handleJoinGameResponse(JoinGameResponse joinGameResponse) {
    if (joinGameResponse.isJoined == true) {
      print('${joinGameResponse.nickname} si è unito al gioco con successo.');
      // Puoi aggiornare lo stato del gioco qui se necessario
    } else {
      print('Unione al gioco fallita per ${joinGameResponse.nickname}.');
      // Gestisci l'errore di unione al gioco
    }

  }

  void handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate) {
    if(calculatingScores){
      //ritardo l'aggiornamento dello stato del giocatore di 3 secondi
      Future.delayed(const Duration(seconds: 3), () {
        _updatePlayerState(playerStateUpdate);
      });
    }else{
      //aggiorno subito lo stato del giocatore
      _updatePlayerState(playerStateUpdate);
    }
  }

  void _updatePlayerState(PlayerStateUpdate playerStateUpdate){
    // Aggiorna lo stato del giocatore nel gioco
    for (var player in game!.players) {
      if (player.getNickname() == playerStateUpdate.nickname) {
        player.setPlayerState(playerStateUpdate.playerState);
        print("Aggiornato stato di ${player.getNickname()} a ${playerStateUpdate.playerState}");
        break;
      }
    }
    notifyListeners();
  }

  void handleSettedBet(SettedBetUpdate settedBetUpdate) {

    for(var p in game!.players){
      if(p.getNickname() == settedBetUpdate.nickname){
        p.setBet(settedBetUpdate.bet);
        break;
      }
    }
  }

  void handleStartingGame(StartingGame startingGame) {

    print("STARTING a GAME !!!!!");
    game = Game();
    //aggiungo altri player alla lista di giocatori nel game
    for(var playerNick in startingGame.connectedPlayers){
      var finded = false;
      for(var p in game!.players){
        if(p.getNickname() == playerNick){
          finded = true;
          break;
        }
      }
      if(!finded){
        if(playerNick != mySelfPlayer!.getNickname()) {
          game!.addPlayer(Player(playerNick));
        } else {
          game!.addPlayer(mySelfPlayer!);
        }
      }
    }
    //players inviati dal server sono già in ordine di turno
    game!.setPlayerOrder(game!.players);

    //faccio navigare la UI alla gameScreen
    currentScreen = AppScreenState.inGame;
  }

  void handleTextMessage(TextMessage textMessage) {}

  void handlePlayerExitGame(PlayerExitGame playerExitGame) {
    //TODO: implementare
  }

  void handleEndGame(EndGame endGame) {

    endGame.gameResult.forEach((nickname, score) {
      print("Giocatore: $nickname, Punteggio finale: $score");
      for(Player p in game!.players){
        if(p.getNickname() == nickname){
          p.setScore(score);
          break;
        }
      }
    });

    currentScreen = AppScreenState.gameOver;
  }

  void handleInfoAfterReconnection(InfoAfterReconnection infoAfterReconnection) {
    int score, bets, roundsWon;
    for(Player p in game!.players){
      score = infoAfterReconnection.scores[p.getNickname()]!;
      bets = infoAfterReconnection.bets[p.getNickname()]!;
      roundsWon = infoAfterReconnection.roundsWon[p.getNickname()]!;
      p.setScore(score);
      p.setBet(bets);
      p.setRoundsWon(roundsWon);
    }
    notifyListeners();
  }

  void endGame(bool didWin) {

    //TODO: in seguito implementare aumento di ex points, premi ecc... in base a didWin
    //reset dello stato del game per prepararsi a un nuovo gioco
    game = null;
    mySelfPlayer!.handCards = [];
    mySelfPlayer!.setScore(0);
    mySelfPlayer!.setBet(0);
    mySelfPlayer!.setRoundsWon(0);
    mySelfPlayer!.clearPlayedCard();
    mySelfPlayer!.setPlayerState(PlayerState.IDLE);

    currentScreen = AppScreenState.mainMenu;
    notifyListeners();
  }


// ... altri metodi come loginWithGoogle, etc.
}
