import 'package:flutter/material.dart';
import 'presentation/screens/gatekeeper.dart';
import 'core/constants/app_colors.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'NSync',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: SplashGatekeeper(),
      ),
    );
  }
}
