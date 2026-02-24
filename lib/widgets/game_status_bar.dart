// ============================================================
// BARRE D'ÉTAT DE JEU
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_models.dart';
import '../services/game_provider.dart';
import '../utils/fantasy_theme.dart';

class GameStatusBar extends StatelessWidget {
  const GameStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FantasyTheme.bgDark, FantasyTheme.bgMedium],
            ),
            border: Border(
              bottom: BorderSide(
                color: FantasyTheme.purple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Indicateur joueur blanc
              _buildPlayerIndicator(
                game,
                PieceColor.white,
                'Blancs',
              ),

              const Spacer(),

              // Status central
              _buildCentralStatus(game),

              const Spacer(),

              // Indicateur joueur noir
              _buildPlayerIndicator(
                game,
                PieceColor.black,
                'Noirs',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerIndicator(
    GameProvider game,
    PieceColor color,
    String label,
  ) {
    final isActive = game.currentTurn == color && !game.isGameOver;
    final isWhite = color == PieceColor.white;
    final activeColor = isWhite ? FantasyTheme.gold : FantasyTheme.purpleLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? activeColor
              : activeColor.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        color: isActive
            ? activeColor.withValues(alpha: 0.15)
            : Colors.transparent,
        boxShadow: isActive
            ? FantasyTheme.glowShadow(activeColor, intensity: 0.3)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWhite ? '♔' : '♚',
            style: TextStyle(
              fontSize: 18,
              shadows: isActive
                  ? [Shadow(color: activeColor, blurRadius: 8)]
                  : [],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : FantasyTheme.silver,
            ),
          ),
          if (isActive && game.isCurrentKingInCheck) ...[
            const SizedBox(width: 4),
            Text(
              '⚠',
              style: TextStyle(
                fontSize: 14,
                color: FantasyTheme.red,
                shadows: [
                  Shadow(color: FantasyTheme.red, blurRadius: 8),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCentralStatus(GameProvider game) {
    if (game.isGameOver) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FantasyTheme.gold.withValues(alpha: 0.5)),
          color: FantasyTheme.goldDark.withValues(alpha: 0.2),
        ),
        child: Text(
          'PARTIE TERMINÉE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: FantasyTheme.gold,
            letterSpacing: 1,
          ),
        ),
      );
    }

    if (game.isDeploymentPhase) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: FantasyTheme.emerald.withValues(alpha: 0.5)),
          color: FantasyTheme.emeraldDark.withValues(alpha: 0.2),
        ),
        child: Text(
          'DÉPLOIEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: FantasyTheme.emerald,
            letterSpacing: 1,
          ),
        ),
      );
    }

    // Phase de jeu
    if (game.isCurrentKingInCheck) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FantasyTheme.red.withValues(alpha: 0.7)),
          color: FantasyTheme.red.withValues(alpha: 0.15),
          boxShadow: FantasyTheme.glowShadow(FantasyTheme.red, intensity: 0.3),
        ),
        child: Text(
          '⚔ ÉCHEC !',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: FantasyTheme.red,
            letterSpacing: 1,
            shadows: [Shadow(color: FantasyTheme.red, blurRadius: 6)],
          ),
        ),
      );
    }

    return Text(
      '${game.moveHistory.length ~/ 2 + 1}',
      style: TextStyle(
        fontSize: 11,
        color: FantasyTheme.silver.withValues(alpha: 0.5),
      ),
    );
  }
}
