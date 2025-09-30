
import 'package:test_socket/model/Card.dart';

class Player {

  final String nickname;
  int score = 0;
  int bet = 0;
  int roundsWon = 0;
  //PlayerState state = PlayerState.WAITING;
  Card? playedCard;

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

  void setPlayedCard(Card card) {
    playedCard = card;
  }

  Card? getPlayedCard() {
    return playedCard;
  }
}