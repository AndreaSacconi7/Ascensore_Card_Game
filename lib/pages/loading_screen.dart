import 'package:flutter/material.dart';

import '../ui/components.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(height: 40),
          SizedBox(height: 28),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
