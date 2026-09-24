import 'package:flutter/foundation.dart';
import 'package:ascensore_client/model/card_game.dart';
import 'package:ascensore_client/model/player.dart';

class Game {

  List<Player> players = [];

  List<Player> playerOrder = [];

  CardGame? briscola;

  int set = 1;
  int round = 1;
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
        debugPrint('Rimuovo il giocatore ${pl.getNickname()}');
        players.remove(pl);
        break;
      }
    }
  }

  void setPlayerOrder(List<Player> newPlayers) {
    playerOrder = newPlayers;
  }

  void setBriscola(CardGame card) {
    briscola = card;
  }

  CardGame? getBriscola() {
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