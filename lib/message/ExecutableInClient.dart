import 'package:test_socket/pages/PageInterface.dart';

abstract class ExecutableInClient {
  // Define the interface for ExecutableInClient
  void execute({required PageInterface page});

  Map<String, dynamic> toJson();
}