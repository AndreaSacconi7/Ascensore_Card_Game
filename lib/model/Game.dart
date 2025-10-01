import 'package:test_socket/model/Card.dart';
import 'package:test_socket/model/Player.dart';

class Game {

  List<Player> players = [];

  Card? briscola;

  int set = 0;
  int round = 0;
  int turn = 0;


  void addPlayer(Player player) {
    players.add(player);
  }

  List<Player> getPlayers() {
    return players;
  }

  void removePlayer(Player player) {
    for(Player pl in players) {
      if(pl.getNickname() == player.getNickname()) {
        print('Rimuovo il giocatore ${pl.getNickname()}');
        players.remove(pl);
        //TODO: modificare playerWidget
        break;
      }
    }
  }

  void setBriscola(Card card) {
    briscola = card;
  }

  Card? getBriscola() {
    return briscola;
  }

  void setSet(int newSet) {
    set = newSet;
  }

  int getSet() {
    return set;
  }

  void setRound(int newRound) {
    round = newRound;
  }

  int getRound() {
    return round;
  }

  void setTurn(int newTurn) {
    turn = newTurn;
  }

  int getTurn() {
    return turn;
  }

}