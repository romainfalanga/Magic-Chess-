// ============================================================
// ÉCRAN D'ACCUEIL - Chess Strategy
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/game_provider.dart';
import '../services/auth_service.dart';
import '../utils/fantasy_theme.dart';
import 'game_screen.dart';
import 'social_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FantasyTheme.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Stack(
        children: [
          // Gradient radial magique
          Positioned(
            top: -size.height * 0.2,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 1.5,
              height: size.width * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FantasyTheme.purple.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width,
              height: size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FantasyTheme.emerald.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Barre profil utilisateur
          _buildProfileBar(context, user),
          const SizedBox(height: 20),
          // Logo / Titre
          _buildTitle(),
          const SizedBox(height: 20),
          // Mini échiquier décoratif
          _buildDecorativeBoard(),
          const SizedBox(height: 20),
          // Description du mode de jeu
          _buildModeDescription(),
          const Spacer(),
          // Boutons
          _buildOnlineButton(context),
          const SizedBox(height: 12),
          _buildPlayButton(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileBar(BuildContext context, User? user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final username = data?['username'] ?? 'Joueur';
        final avatar = data?['avatar'] ?? '♙';
        final wins = data?['wins'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: FantasyTheme.cardDecoration(
            borderColor: FantasyTheme.gold.withValues(alpha: 0.3),
            borderRadius: 20,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: FantasyTheme.purpleGradient,
                ),
                child: Center(child: Text(avatar, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username,
                        style: TextStyle(
                            color: FantasyTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text('$wins victoires',
                        style: TextStyle(
                            color: FantasyTheme.silver, fontSize: 11)),
                  ],
                ),
              ),
              // Bouton amis
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SocialScreen())),
                icon: Icon(Icons.people_outline,
                    color: FantasyTheme.purpleLight, size: 24),
                tooltip: 'Amis',
              ),
              // Déconnexion
              IconButton(
                onPressed: () => AuthService.signOut(),
                icon: Icon(Icons.logout,
                    color: FantasyTheme.silver.withValues(alpha: 0.6),
                    size: 20),
                tooltip: 'Se déconnecter',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnlineButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SocialScreen())),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: FantasyTheme.emerald.withValues(alpha: 0.6)),
          color: FantasyTheme.emerald.withValues(alpha: 0.1),
          boxShadow: FantasyTheme.glowShadow(FantasyTheme.emerald, intensity: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              'JOUER EN LIGNE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: FantasyTheme.emerald,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Icône magique
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FantasyTheme.purpleGradient,
            boxShadow: FantasyTheme.glowShadow(FantasyTheme.purple),
          ),
          child: const Center(
            child: Text(
              '♟',
              style: TextStyle(fontSize: 42),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'CHESS',
          style: FantasyTheme.titleStyle.copyWith(
            fontSize: 36,
            letterSpacing: 8,
          ),
        ),
        Text(
          'STRATEGY',
          style: FantasyTheme.titleStyle.copyWith(
            fontSize: 20,
            color: FantasyTheme.emerald,
            letterSpacing: 10,
            shadows: [Shadow(color: FantasyTheme.emerald, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                FantasyTheme.gold.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeBoard() {
    // Mini échiquier 4x4 décoratif
    final pieces = [
      ['♜', '♞', '♝', '♛'],
      ['♟', '♟', '♟', '♟'],
      ['♙', '♙', '♙', '♙'],
      ['♖', '♘', '♗', '♕'],
    ];

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(
          color: FantasyTheme.purple.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: FantasyTheme.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: 16,
        itemBuilder: (ctx, i) {
          final row = i ~/ 4;
          final col = i % 4;
          final isLight = (row + col) % 2 == 0;
          return Container(
            color: isLight ? FantasyTheme.lightSquare : FantasyTheme.darkSquare,
            child: Center(
              child: Text(
                pieces[row][col],
                style: const TextStyle(fontSize: 22),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FantasyTheme.cardDecoration(
        borderColor: FantasyTheme.gold.withValues(alpha: 0.3),
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: FantasyTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Mode Déploiement Stratégique',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: FantasyTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Les pions sont déjà en place',
              FantasyTheme.emerald),
          const SizedBox(height: 6),
          _buildStep(
              '2',
              'Tour à tour, placez vos 8 pièces sur votre première rangée',
              FantasyTheme.purpleLight),
          const SizedBox(height: 6),
          _buildStep('3',
              'Observez l\'adversaire et adaptez votre déploiement',
              FantasyTheme.orange),
          const SizedBox(height: 6),
          _buildStep('4', 'La partie commence une fois tous déployés',
              FantasyTheme.silver),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.7)),
            color: color.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: FantasyTheme.silver.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final game = context.read<GameProvider>();
        game.newGame();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, anim, _) => const GameScreen(),
            transitionsBuilder: (ctx, anim, _, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: FantasyTheme.purpleGradient,
          boxShadow: FantasyTheme.glowShadow(FantasyTheme.purple),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              'COMMENCER LA PARTIE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FantasyTheme.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: FantasyTheme.white.withValues(alpha: 0.3), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
