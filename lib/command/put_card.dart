import 'package:ascensore_client/command/executable_in_server.dart';

import '../model/seed.dart';

class PutCard implements ExecutableInServer {

  final Seed seed;
  final int value;
  final String nickname;

  PutCard(this.seed, this.value, this.nickname);

  @override
  Map<String, dynamic> toJson() {

    final executableArgs = {
      "seed": seed.toString().split('.').last,
      "value": value,
      "nickname": nickname,
    };
    return executableArgs;
  }


}