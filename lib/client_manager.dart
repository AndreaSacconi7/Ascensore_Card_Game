import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ascensore_client/app_screen_state.dart';
import 'package:ascensore_client/message/end_game.dart';
import 'package:ascensore_client/message/info_after_reconnection.dart';
import 'package:ascensore_client/message/join_game_response.dart';
import 'package:ascensore_client/message/player_exit_game.dart';
import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/set_result_animation_state.dart';
import 'package:ascensore_client/model/seed.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

import 'authentication_state.dart';
import 'command/command.dart';
import 'command/command_type.dart';
import 'command/logout.dart';
import 'command/player_info_request.dart';
import 'message/briscola_update.dart';
import 'message/end_round_update.dart';
import 'message/end_set_update.dart';
import 'message/executable_in_client.dart';
import 'message/hand_update.dart';
import 'message/login_response.dart';
import 'message/played_card_update.dart';
import 'message/player_info_response.dart';
import 'message/player_state_update.dart';
import 'message/setted_bet_update.dart';
import 'message/starting_game.dart';
import 'message/text_message.dart';
import 'model/game.dart';
import 'model/my_self_player.dart';
import 'model/player.dart';
import 'model/player_state.dart';

// Stato globale del client: connessione WebSocket, autenticazione e partita.
class ClientManager extends ChangeNotifier {
  WebSocketChannel? channel;
  StreamSubscription? _stream;

  // Stato di gioco e autenticazione
  MySelfPlayer? mySelfPlayer;
  Game? game;
  bool isAuthenticated = false;
  AuthenticationState authState = AuthenticationState.unknown;
  String? authError;
  AppScreenState currentScreen = AppScreenState.login;
  bool calculatingScores = false;

  SetResultAnimationState lastSetResult = SetResultAnimationState.none;

  void setCurrentScreen(AppScreenState newScreen) {
    currentScreen = newScreen;
    notifyListeners();
  }

  MySelfPlayer? getMySelfPlayer() {
    return mySelfPlayer;
  }

  void sendCommand(dynamic jsonCommand) {
    log('Sending command to server: $jsonCommand');

    channel!.sink.add(jsonCommand);
  }

  // Deserializza il messaggio, lo esegue sullo stato e notifica la UI
  void _handleMessage(dynamic jsonMessage) {
    debugPrint('Message from server: $jsonMessage');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonMessage);
    final String stringMessageType = jsonMap['messageType'];

    // Identifica l'eseguibile in base al tipo di messaggio
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
      debugPrint('Unknown message type: ${jsonMap['messageType']}');
      return;
    }

    // L'eseguibile ora modifica i dati DENTRO il ClientManager
    executable.execute(clientManager: this);

    // Dopo che i dati sono stati aggiornati, avvisa tutti
    // i widget in ascolto
    notifyListeners();
  }

  // URL del server: sovrascrivibile con --dart-define=SERVER_URL=ws://host:port/ws
  static const String _serverUrlOverride = String.fromEnvironment('SERVER_URL');
  static String get _serverUrl => _serverUrlOverride.isNotEmpty
      ? _serverUrlOverride
      : (kIsWeb ? 'ws://localhost:8080/ws' : 'ws://10.0.2.2:8080/ws');

  // Metodo per connettersi (chiamato al Login o signUp)
  void connect() {
    if (channel != null) return; // Già connesso

    try {
      channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

      // Mettiamoci in ascolto
      _stream = channel!.stream.listen(
            (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint("Errore Socket: $error");
          logOut(); // Disconnetti in caso di errore
        },
        onDone: () {
          debugPrint("Socket chiuso dal server");
          logOut(); // Pulisci tutto se il server chiude
        },
      );
    } catch (e) {
      debugPrint("Impossibile connettersi: $e");
      notifyListeners();
    }
  }


  Future<void> logOut() async {
    // Chiude la sessione Supabase (cancella il token locale)
    await Supabase.instance.client.auth.signOut();

    // Avvisa il server, se la connessione è ancora aperta
    if (channel != null) {
      try {
        sendCommand(Command(commandType: CommandType.LOGOUT, executable: Logout()).toJson());
      } catch (e) {
        debugPrint("Impossibile inviare il logout: $e");
      }
    }

    await _stream?.cancel(); // Smetti di ascoltare
    _stream = null;

    channel?.sink.close(); // Chiudi il socket
    channel = null;        // Resetta la variabile per il prossimo login

    //resetto lo stato del client manager
    mySelfPlayer = null;
    game = null;
    lastSetResult = SetResultAnimationState.none;

    // Torna alla schermata di login
    authState = AuthenticationState.unauthenticated;
    authError = null;
    isAuthenticated = false;
    currentScreen = AppScreenState.login;
    notifyListeners();

    debugPrint("Logout effettuato. Token cancellato.");
  }

  // --- AZIONI CHIAMATE DALLA UI ---
  /// Controlla se un token è già salvato all'avvio dell'app
  Future<void> checkLoginStatus() async {

    authState = AuthenticationState.loading;
    notifyListeners();

    // Supabase ha una sessione salvata?
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {

      if(session.isExpired){
        try {
          // Forza il refresh del token
          final response = await Supabase.instance.client.auth.refreshSession();
          final freshToken = response.session?.accessToken;

          if (freshToken != null) {
            debugPrint("Token rinnovato con successo!");
            _fetchPlayerInfoWithExistingToken(freshToken);
          } else {
            debugPrint("Impossibile rinnovare. Logout forzato.");
            logOut();
          }
        } catch (e) {
          debugPrint("Errore durante il refresh del token: ${e.toString()}");
          logOut();
        }
      }else{
        // Token ancora valido: autenticazione diretta col server
        debugPrint("Sessione Supabase trovata.");
        _fetchPlayerInfoWithExistingToken(session.accessToken);
      }

    } else {
      // Nessuna sessione salvata, l'utente deve fare il login manuale
      debugPrint("Nessuna sessione trovata.");
      isAuthenticated = false;
      authState = AuthenticationState.unauthenticated;
      currentScreen = AppScreenState.login;
    }

    notifyListeners();
  }

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
      p.setPlayedCard(CardGame(Seed.VOID, 0));
    }
    notifyListeners();
  }

  void _clearBoardForNextSet(){
    for(var p in game!.players){
      p.setPlayedCard(CardGame(Seed.VOID, 0));
      p.setRoundsWon(0);
      p.setBet(0);
    }
    notifyListeners();
  }

  void handleHandUpdate(HandUpdate handUpdate) {

    mySelfPlayer?.setHandCards(handUpdate.handCards);
  }

  void handlePlayerInfo(PlayerInfoResponse playerInfoResponse) {

    if (playerInfoResponse.isLogged) {
      debugPrint('Welcome, ${playerInfoResponse.nickname}');


      isAuthenticated = true;
      authState = AuthenticationState.authenticated;
      currentScreen = AppScreenState.mainMenu;

      mySelfPlayer = MySelfPlayer(playerInfoResponse.nickname);
    } else {
      debugPrint('Login failed');
      // FALLIMENTO!
      isAuthenticated = false;
      authState = AuthenticationState.error;
      authError = "Login fallito.";
    }
  }

  void handleJoinGameResponse(JoinGameResponse joinGameResponse) {
    if (joinGameResponse.isJoined == true) {
      debugPrint('${joinGameResponse.nickname} si è unito al gioco con successo.');
      // Puoi aggiornare lo stato del gioco qui se necessario
    } else {
      debugPrint('Unione al gioco fallita per ${joinGameResponse.nickname}.');
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
        debugPrint("Aggiornato stato di ${player.getNickname()} a ${playerStateUpdate.playerState}");
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

    debugPrint("STARTING a GAME !!!!!");
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
      debugPrint("Giocatore: $nickname, Punteggio finale: $score");
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
