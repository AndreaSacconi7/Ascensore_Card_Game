
import '../client_manager.dart';

abstract class ExecutableInClient {
  // Define the interface for ExecutableInClient
  void execute({required ClientManager clientManager});


  ExecutableInClient.fromJson(Map<String, dynamic> json);
}