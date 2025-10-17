
import 'package:flutter/material.dart';
import 'package:test_socket/model/CardGame.dart';
import 'package:test_socket/model/PlayerState.dart';

class Player {

  final String nickname;
  int score = 0;
  final ValueNotifier<int> betNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> roundsWonNotifier = ValueNotifier<int>(0);
  //PlayerState state = PlayerState.WAITING;
  final ValueNotifier<CardGame?> playedCardNotifier = ValueNotifier<CardGame?>(null);
  PlayerState playerState = PlayerState.IDLE;

  Player(this.nickname);

  void setScore(int newScore) {
    score = newScore;
  }

  int getScore() {
    return score;
  }

  String getNickname() {
    return nickname;
  }

  void setBet(int newBet) {
    betNotifier.value = newBet; // Aggiorna il valore e notifica i listener
  }

  int getBet() {
    return betNotifier.value;
  }

  void setRoundsWon(int newRoundsWon) {
    roundsWonNotifier.value = newRoundsWon;
  }

  int getRoundsWon() {
    return roundsWonNotifier.value;
  }

  void setPlayedCard(CardGame? card) {
    playedCardNotifier.value = card;        // Aggiorna il valore e notifica i listener
  }

  void clearPlayedCard() {
    playedCardNotifier.value = null;        // Aggiorna il valore e notifica i listener
  }

  CardGame? getPlayedCard() {
    return playedCardNotifier.value;
  }

  void setPlayerState(PlayerState newState) {
    playerState = newState;
  }

  PlayerState getPlayerState() {
    return playerState;
  }
}