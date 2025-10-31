import 'package:test_socket/pages/PageInterface.dart';

import '../ClientManager.dart';

abstract class ExecutableInClient {
  // Define the interface for ExecutableInClient
  void execute({required ClientManager clientManager});

  //Map<String, dynamic> toJson();

  ExecutableInClient.fromJson(Map<String, dynamic> json);
}