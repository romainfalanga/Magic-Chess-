// ============================================================
// MAIN.DART - Magic Chess avec Firebase
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

  // Orientation portrait uniquement sur mobile
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
        home: const FirebaseInitScreen(),
      ),
    );
  }
}

// Initialise Firebase de manière asynchrone DANS le widget tree
// Évite les crashs au démarrage sur le web
class FirebaseInitScreen extends StatefulWidget {
  const FirebaseInitScreen({super.key});

  @override
  State<FirebaseInitScreen> createState() => _FirebaseInitScreenState();
}

class _FirebaseInitScreenState extends State<FirebaseInitScreen> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Erreur Firebase
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0A1A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de connexion',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB0B0C8), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _initFirebase();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FBE),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Chargement Firebase
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('♟', style: TextStyle(fontSize: 56)),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color(0xFF7B2FBE)),
              SizedBox(height: 16),
              Text(
                'MAGIC CHESS',
                style: TextStyle(
                  color: Color(0xFF7B2FBE),
                  fontSize: 14,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Firebase prêt → portail Auth
    return const AuthGate();
  }
}

// Redirige selon l'état de connexion
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0A1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7B2FBE)),
            ),
          );
        }
        if (snapshot.hasData) return const HomeScreen();
        return const AuthScreen();
      },
    );
  }
}
