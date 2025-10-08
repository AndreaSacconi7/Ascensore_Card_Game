import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/BriscolaUpdate.dart';
import 'package:test_socket/message/HandUpdate.dart';
import 'package:test_socket/message/Message.dart';
import 'package:test_socket/message/StartingGame.dart';

import '../message/LoginResponse.dart';

abstract class PageInterface {

  late ClientManager _clientManager;

  handleLoginResponse(LoginResponse response);

  handleHandUpdate(HandUpdate handUpdate);

  handleBriscolaUpdate(BriscolaUpdate briscolaUpdate);

  handleStartingGame(StartingGame startingGame) {}
}