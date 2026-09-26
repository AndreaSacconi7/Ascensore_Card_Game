import '../client_manager.dart';

/// Payload of a server message; applies itself to the client state.
abstract class ExecutableInClient {
  void execute({required ClientManager clientManager});
}

/// Reads a JSON object of nickname -> int, keeping the server's key order (it carries meaning).
Map<String, int> intMap(dynamic json) =>
    (json as Map<String, dynamic>? ?? const {}).map((key, value) => MapEntry(key, value as int));
