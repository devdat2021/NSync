// import 'package:bunk_analysis/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/gatekeeper.dart';
// import 'core/security/credential_vault.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSync',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      // darkTheme: ThemeData.dark(),
      // 2. The dark theme config
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.deepPurple,
      //     brightness: Brightness.dark,
      //   ),
      // ),

      // 3. Tells Flutter to automatically switch based on device settings
      themeMode: ThemeMode.system,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 118, 193, 222),
      //     brightness: Brightness.dark, // This forces the dark theme palette
      //   ),
      // ),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 224, 147, 147),
      //   ),
      // ),
      // home: const HomePage(title: 'NSync'),
      //home: const LoginScreen(),
      home: SplashGatekeeper(),
    );
  }
}
