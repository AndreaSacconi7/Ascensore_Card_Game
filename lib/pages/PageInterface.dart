import 'package:test_socket/ClientManagerOld.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/EndRoundUpdate.dart';
import 'package:test_socket/message/EndSetUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/Message.dart';
import 'package:test_socket/message/PlayedCardUpdate.dart';
import 'package:test_socket/message/PlayerStateUpdate.dart';
import 'package:test_socket/message/SettedBetUpdate.dart';
import 'package:test_socket/message/StartingGame.dart';
import 'package:test_socket/message/TextMessage.dart';

import '../ClientManager.dart';
import '../message/LoginResponse.dart';

abstract class PageInterface {

  late ClientManager _clientManager;

  handleLoginResponse(LoginResponse response);

  handleHandUpdate(HandUpdate handUpdate);

  handleBriscolaUpdate(BriscolaUpdate briscolaUpdate);

  handleStartingGame(StartingGame startingGame);

  handlePlayerStateUpdate(PlayerStateUpdate playerStateUpdate);

  handleTextMessage(TextMessage textMessage);

  handleEndRoundUpdate(EndRoundUpdate endRoundUpdate);

  handleEndSetUpdate(EndSetUpdate endSetUpdate);

  handlePlayedCard(PlayedCardUpdate playedCardUpdate);

  handleSettedBet(SettedBetUpdate settedBetUpdate);
}