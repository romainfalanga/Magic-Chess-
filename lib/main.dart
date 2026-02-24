// ============================================================
// MAIN.DART - Chess Strategy avec Firebase
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/game_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        title: 'Magic Chess',
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
        home: const AuthGate(),
      ),
    );
  }
}

// Portail Auth - redirige selon l'état de connexion
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0A1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7B2FBE)),
            ),
          );
        }
        // Connecté → accueil
        if (snapshot.hasData) return const HomeScreen();
        // Non connecté → auth
        return const AuthScreen();
      },
    );
  }
}
