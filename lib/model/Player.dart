
import 'package:test_socket/model/CardGame.dart';
import 'package:test_socket/model/PlayerState.dart';

class Player {

  final String nickname;
  int score = 0;
  int bet = 0;
  int roundsWon = 0;
  //PlayerState state = PlayerState.WAITING;
  CardGame? playedCard;
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
    bet = newBet;
  }

  int getBet() {
    return bet;
  }

  void setRoundsWon(int newRoundsWon) {
    roundsWon = newRoundsWon;
  }

  int getRoundsWon() {
    return roundsWon;
  }

  void setPlayedCard(CardGame card) {
    playedCard = card;
  }

  CardGame? getPlayedCard() {
    return playedCard;
  }

  void setPlayerState(PlayerState newState) {
    playerState = newState;
  }

  PlayerState getPlayerState() {
    return playerState;
  }
}