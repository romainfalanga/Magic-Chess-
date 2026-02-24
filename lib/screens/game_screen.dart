// ============================================================
// ÉCRAN PRINCIPAL DE JEU
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_models.dart';
import '../services/game_provider.dart';
import '../utils/fantasy_theme.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/deployment_panel.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/game_status_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        return Scaffold(
          backgroundColor: FantasyTheme.bgDark,
          body: SafeArea(
            child: Stack(
              children: [
                // Fond avec particules
                _buildBackground(),

                // Contenu principal
                Column(
                  children: [
                    // Barre de statut
                    const GameStatusBar(),

                    // Échiquier
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: FantasyTheme.purple.withValues(alpha: 0.5),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        FantasyTheme.purple.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                  BoxShadow(
                                    color: FantasyTheme.emerald.withValues(alpha: 0.15),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRect(
                                child: const ChessBoardWidget(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Panneau de déploiement ou panneau de jeu
                    if (game.isDeploymentPhase)
                      const DeploymentPanel()
                    else if (game.isPlayingPhase)
                      _buildPlayingPanel(context, game)
                    else if (game.isGameOver)
                      _buildGameOverPanel(context, game),
                  ],
                ),

                // Overlay de promotion
                if (game.pendingPromotion != null)
                  const Positioned.fill(child: PromotionDialog()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlesPainter(),
      ),
    );
  }

  Widget _buildPlayingPanel(BuildContext context, GameProvider game) {
    final isWhiteTurn = game.currentTurn == PieceColor.white;
    final activeColor = isWhiteTurn ? FantasyTheme.gold : FantasyTheme.purpleLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FantasyTheme.bgMedium, FantasyTheme.bgDark],
        ),
        border: Border(
          top: BorderSide(
            color: activeColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  color: activeColor.withValues(alpha: 0.1),
                  boxShadow:
                      FantasyTheme.glowShadow(activeColor, intensity: 0.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isWhiteTurn ? '♔' : '♚',
                      style: TextStyle(
                        fontSize: 22,
                        shadows: [Shadow(color: activeColor, blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isWhiteTurn ? "Blancs" : "Noirs"} jouent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Coup numéro
              Text(
                'Coup ${game.moveHistory.length ~/ 2 + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: FantasyTheme.silver.withValues(alpha: 0.6),
                ),
              ),
              // Bouton abandon
              TextButton.icon(
                onPressed: () => _showResignDialog(context, game),
                icon: Icon(Icons.flag_outlined,
                    color: FantasyTheme.red.withValues(alpha: 0.7), size: 16),
                label: Text(
                  'Abandonner',
                  style: TextStyle(
                    color: FantasyTheme.red.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FantasyTheme.bgMedium, FantasyTheme.bgDark],
        ),
        border: Border(
          top: BorderSide(
            color: FantasyTheme.gold.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: FantasyTheme.gold.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophée animé
          Text(
            '🏆',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            game.gameResult ?? 'Partie terminée',
            style: FantasyTheme.titleStyle.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton nouvelle partie
              ElevatedButton.icon(
                onPressed: () => game.newGame(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Nouvelle partie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FantasyTheme.purple,
                  foregroundColor: FantasyTheme.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  shadowColor: FantasyTheme.purple.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResignDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FantasyTheme.bgMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: FantasyTheme.red.withValues(alpha: 0.5), width: 1),
        ),
        title: Text(
          'Abandonner ?',
          style: FantasyTheme.titleStyle.copyWith(
            fontSize: 20,
            color: FantasyTheme.red,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment abandonner la partie ?',
          style: FantasyTheme.subtitleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: TextStyle(color: FantasyTheme.silver)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              game.resign();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FantasyTheme.red.withValues(alpha: 0.3),
              foregroundColor: FantasyTheme.red,
            ),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }
}

// Peintre de fond avec effet de grille magique
class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FantasyTheme.purple.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Grille subtile
    final spacing = size.width / 12;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
