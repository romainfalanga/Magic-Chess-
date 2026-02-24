// ============================================================
// MAIN.DART - Point d'entrée Chess Strategy
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ChessStrategyApp());
}

class ChessStrategyApp extends StatelessWidget {
  const ChessStrategyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..initGame(),
      child: MaterialApp(
        title: 'Chess Strategy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7B2FBE),
            secondary: Color(0xFF00C97A),
            surface: Color(0xFF1A1530),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0A1A),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
