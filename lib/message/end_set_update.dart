import '../client_manager.dart';
import 'executable_in_client.dart';

/// A set is over.
class EndSetUpdate implements ExecutableInClient {
  /// Scores per player, keyed in the betting order of the next set.
  final Map<String, int> nextPlayerOrderAndScore;

  /// Hand size of the next set.
  final int nextSetNumber;

  EndSetUpdate.fromJson(Map<String, dynamic> json)
      : nextPlayerOrderAndScore = intMap(json['nextPlayerOrderAndScore']),
        nextSetNumber = json['nextSetNumber'] as int;

  @override
  void execute({required ClientManager clientManager}) => clientManager.handleEndSetUpdate(this);
}
