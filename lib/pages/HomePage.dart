import 'package:flutter/material.dart';
import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/command/Command.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/EndRoundUpdate.dart';
import 'package:test_socket/message/EndSetUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/LoginResponse.dart';
import 'package:test_socket/message/PlayedCardUpdate.dart';
import 'package:test_socket/message/PlayerStateUpdate.dart';
import 'package:test_socket/message/SettedBetUpdate.dart';
import 'package:test_socket/message/StartingGame.dart';
import 'package:test_socket/message/TextMessage.dart';
import 'package:test_socket/model/Game.dart';
import 'package:test_socket/model/Player.dart';
import 'package:test_socket/model/Seed.dart';
import 'package:test_socket/pages/PageInterface.dart';
import 'package:test_socket/widgets/BetWidget.dart';
import 'package:test_socket/widgets/ScoreWidget.dart';
import 'package:test_socket/widgets/TakenWidget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../command/CommandType.dart';
import '../command/PutCard.dart';
import '../command/SetBet.dart';
import '../model/CardGame.dart';
import '../model/PlayerState.dart';
import '../widgets/CardWidget.dart';
import '../widgets/HandCards.dart';
import '../widgets/MySelfTakenBetScore.dart';
import '../widgets/PlayedCardWidget.dart';
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

  CardGame? droppedCard; // Variabile per tenere traccia della carta rilasciata

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

    final jsonCommand = command.toJson();
    widget.clientManager.sendCommand(jsonCommand);
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
      /*appBar: AppBar(
          //TODO: qua poi posso mettere qualche info di gioco
          title: Text('Ascensore Game'),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Late',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff1f2023),
      ),*/
      body: Stack(
        children: [
          _buildDropZone(),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Riga in alto con i giocatori
                _buildPlayersRow(),

                SizedBox(height: 40),

                // Riga con la carta giocata in alto
                _buildTopCardRow(),

                SizedBox(height: 30),

                // Riga centrale con le carte giocate dai giocatori e la briscola
                _buildMiddleRow(),

                SizedBox(height: 30),

                //_buildDropZone(),

                _buildMySelfPlayedCardRow(),

                SizedBox(height: 30),

                _buildBetAndTakenRow(),

                //FanHandWidget(handCards: widget.clientManager.mySelfPlayer!.handCards, onPlayCard: (card) {}),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //_buildBetAndTakenRow(),
                      //_buildHandCardsBar(),
                      HandCards(clientManager: widget.clientManager),
                      //HandCardsBar(clientManager: widget.clientManager),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        player: player,
      )).toList()
          : [Text('No players available yet')],
    );
  }

  Widget _buildTopCardRow() {
    final topPlayer = game.players.isNotEmpty ? game.players[0] : null;
    return topPlayer?.playedCardNotifier.value != null
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlayedCardWidget(playedCardNotifier: topPlayer!.playedCardNotifier)],
    )
        : SizedBox.shrink();
  }

  Widget _buildMiddleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayerCard(1),
        SizedBox(width: 60),
        _buildBriscolaCard(),
        SizedBox(width: 60),
        _buildPlayerCard(2),
      ],
    );
  }

  Widget _buildMySelfPlayedCardRow(){
    final mySelfPlayer = widget.clientManager.mySelfPlayer;
    return mySelfPlayer?.playedCardNotifier.value != null
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlayedCardWidget(playedCardNotifier: mySelfPlayer!.playedCardNotifier)],
    )
        : SizedBox.shrink();
  }

  Widget _buildPlayerCard(int playerIndex) {
    final player = game.players.length > playerIndex ? game.players[playerIndex] : null;
    return player?.playedCardNotifier.value != null
        ? PlayedCardWidget(playedCardNotifier: player!.playedCardNotifier)
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
                        if(checkIfValidBet(sliderValue.toInt())){
                          Navigator.of(context).pop(); // Close the overlay
                          widget.clientManager.mySelfPlayer?.setBet(sliderValue.toInt());
                          print('Bet confirmed: ${widget.clientManager.mySelfPlayer?.getBet()}');
                          //imposto il valore del bet nel player e nel BetWidget
                          widget.clientManager.mySelfPlayer!.setBet(sliderValue.toInt());
                          //invio command con il bet al server
                          SetBet setBetExecutable = SetBet(bet: sliderValue.toInt(), nickname: widget.clientManager.mySelfPlayer!.getNickname());

                          Command command = Command(
                            commandType: CommandType.SET_BET,
                            executable: setBetExecutable,
                            nickName: widget.clientManager.mySelfPlayer!.getNickname(),
                          );
                          _sendCommand(command);
                        }else{
                          showMessage('Invalid bet! Please choose a different value.');
                        }
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
    return Row(
      children: [
        MySelfBetTakenScoreWidget(player: widget.clientManager.mySelfPlayer!),
        //HoverLiftExample(child: CardWidget(card: game.briscola!)),
        //ScrollHoverCards(colors: [Colors.black, Colors.blue, Colors.red, Colors.green, Colors.orange]),
      ],
    );
    /*return Column(
      children:[
        Row(
          children: [
            const Padding(padding:
              EdgeInsets.only(
                right: 45,
              )
            ),
            ScoreWidget(scoreNotifier: widget.clientManager.mySelfPlayer!.scoreNotifier),
          ],
        ),
        Row(
          children: [
            BetWidget(betNotifier: widget.clientManager.mySelfPlayer!.betNotifier),
            TakenWidget(roundsWonNotifier: widget.clientManager.mySelfPlayer!.roundsWonNotifier),
          ],
        ),
      ],
    );*/
  }

  Widget _buildDropZone() {
    return Positioned.fill(
      bottom: MediaQuery.of(context).size.height / 4, // Altezza iniziale della dropZone
      child: DragTarget<CardGame>(
        onAcceptWithDetails: (details) {
          setState(() {
            droppedCard = details.data;

            if (_isValidPutCard(droppedCard!)) {
              widget.clientManager.mySelfPlayer?.removeCardFromHand(droppedCard!);
              widget.clientManager.mySelfPlayer?.setPlayedCard(droppedCard!);

              PutCard putCardExecutable = PutCard(
                droppedCard!.seed,
                droppedCard!.value,
                widget.clientManager.mySelfPlayer!.getNickname(),
              );
              Command command = Command(
                commandType: CommandType.PUT_CARD,
                executable: putCardExecutable,
                nickName: widget.clientManager.mySelfPlayer!.getNickname(),
              );
              _sendCommand(command);
            }
          });
        },
        builder: (BuildContext context, List<CardGame?> candidateData, List<dynamic> rejectedData) {
          return Container(
            //color: Colors.green.withOpacity(0.1),
            child: Center(
              child: Text(
                candidateData.isNotEmpty ? 'Drop here!' : '',
                style: TextStyle(
                  color: candidateData.isNotEmpty ? Colors.red : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isValidPutCard(CardGame card) {

    if(widget.clientManager.mySelfPlayer!.playerState != PlayerState.PUT){
      showMessage('You cannot play now, wait for your turn!');
      return false;
    }else{
      if(game.playerOrder[0].nickname == widget.clientManager.mySelfPlayer!.nickname){
        //se sono il primo giocatore a dover giocare allora posso giocare qualsiasi carta
        return true;
      }else if(game.playerOrder[0].playedCardNotifier.value == null || game.playerOrder[0].playedCardNotifier.value!.seed == card.seed){
        //se la carta giocata ha lo stesso seed della prima carta giocata allora è valida
        return true;
      }
      for(CardGame c in widget.clientManager.mySelfPlayer!.handCards){
        if(c.seed == game.playerOrder[0].playedCardNotifier.value!.seed && c != card){
          //se il player ha in mano una carta dello stesso seed rispetto la prima carta giocata deve giocarla
          showMessage('You must play a card of the same seed as the first played card!');
          return false;
        }
      }
      //player non ha carte dello stesso seed (rispetto la prima carta giocata) quindi può giocare liberamente
      return true;
    }
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
          if(playerNick != widget.clientManager.mySelfPlayer!.getNickname()) {
            game.addPlayer(Player(playerNick));
          } else {
            game.addPlayer(widget.clientManager.mySelfPlayer!);
          }
        }
      }
      //players inviati dal server sono già in ordine di turno
      game.setPlayerOrder(game.players);
    });
  }

  @override
  handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate) {

    showMessage('Player ${playerStateUpdate.nickname} is now in ${playerStateUpdate.playerState.toString().split('.').last} state');

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

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(textMessage.text)),
    );
  }

  showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  handleEndRoundUpdate(EndRoundUpdate endRoundUpdate) {

    setState(() {
      List<Player> newPlayerOrder = [];
      for(String nickname in endRoundUpdate.nextPlayerOrderAndTaken.keys){
        for(Player p in game.players){
          if(p.getNickname() == nickname){
            p.setRoundsWon(endRoundUpdate.nextPlayerOrderAndTaken[nickname]!);
            newPlayerOrder.add(p);
            break;
          }
        }
      }

      game.setPlayerOrder(newPlayerOrder);

      game.setSet(endRoundUpdate.nextRoundNumber);

      for(var p in game.players){
        p.setPlayedCard(new CardGame(Seed.VOID, 0));
      }
    });
  }

  @override
  handleEndSetUpdate(EndSetUpdate endSetUpdate) {

    setState(() {
      List<Player> newPlayerOrder = [];

      for(String nickname in endSetUpdate.nextPlayerOrderAndScore.keys){
        for(Player p in game.players){
          if(p.getNickname() == nickname){
            p.setScore(endSetUpdate.nextPlayerOrderAndScore[nickname]!);
            newPlayerOrder.add(p);
            break;
          }
        }
      }

      game.setPlayerOrder(newPlayerOrder);

      game.setSet(endSetUpdate.nextSetNumber);

      for(var p in game.players){
        p.setPlayedCard(new CardGame(Seed.VOID, 0));
        p.setRoundsWon(0);
        p.setBet(0);
      }
    });
  }

  @override
  handlePlayedCard(PlayedCardUpdate playedCardUpdate) {

    setState(() {
      for(var p in game.players){
        if(p.getNickname() == playedCardUpdate.nickname){
          p.setPlayedCard(playedCardUpdate.playedCard);
          break;
        }
      }
    });
  }

  @override
  handleSettedBet(SettedBetUpdate settedBetUpdate) {

    setState(() {
      for(var p in game.players){
        if(p.getNickname() == settedBetUpdate.nickname){
          p.setBet(settedBetUpdate.bet);
          break;
        }
      }
    });
  }


  bool checkIfValidBet(int bet) {
    int totalBets = bet;
    //se non sono l'ultimo posso scommettere liberamente
    if(game.playerOrder[game.playerOrder.length -1].nickname != widget.clientManager.getMySelfPlayer()!.nickname) {
      return true;
    }
    //eseguo questa parte solo se sono l'ultimo a dover scommettere
    for(Player p in game.playerOrder){
      totalBets += p.getBet();
    }
    if(totalBets == game.getSet()){
      return false;
    }
    return true;
  }

}