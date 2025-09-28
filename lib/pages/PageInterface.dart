import 'package:test_socket/ClientManager.dart';
import 'package:test_socket/message/Message.dart';

import '../message/LoginResponse.dart';

abstract class PageInterface {

  late ClientManager _clientManager;

  handleLoginResponse(LoginResponse response);
}