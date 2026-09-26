import 'package:flutter/material.dart';

import 'app_wrapper.dart';
import 'ui/theme.dart';

class AscensoreApp extends StatelessWidget {
  const AscensoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascensore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AppWrapper(),
    );
  }
}
