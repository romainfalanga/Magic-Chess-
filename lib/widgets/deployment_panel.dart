// ============================================================
// PANNEAU DE DÉPLOIEMENT - Phase de placement
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_models.dart';
import '../services/game_provider.dart';
import '../utils/fantasy_theme.dart';

class DeploymentPanel extends StatelessWidget {
  const DeploymentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final isWhiteTurn = game.currentTurn == PieceColor.white;
        final pieces = game.currentPlayerPiecesToDeploy;
        final alreadyDeployed = _getDeployedPieces(game);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                FantasyTheme.bgMedium,
                FantasyTheme.bgDark,
              ],
            ),
            border: Border(
              top: BorderSide(
                color: isWhiteTurn
                    ? FantasyTheme.gold.withValues(alpha: 0.5)
                    : FantasyTheme.purple.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicateur de tour
              _buildTurnIndicator(game, isWhiteTurn),
              const SizedBox(height: 8),

              // Instruction
              if (pieces.isNotEmpty) ...[
                Text(
                  game.selectedDeployPiece != null
                      ? 'Tapez une case sur votre rangée pour placer'
                      : 'Choisissez une pièce à déployer',
                  style: TextStyle(
                    fontSize: 12,
                    color: FantasyTheme.silver.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Pièces à déployer
                _buildPieceSelector(context, game, pieces, isWhiteTurn),
              ] else ...[
                // Ce joueur a fini de déployer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FantasyTheme.emerald.withValues(alpha: 0.5),
                    ),
                    color: FantasyTheme.emeraldDark.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: FantasyTheme.emerald, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Déploiement terminé — En attente...',
                        style: TextStyle(
                            color: FantasyTheme.emerald, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],

              // Pièces déjà déployées (pour ce joueur)
              if (alreadyDeployed.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDeployedPreview(alreadyDeployed, isWhiteTurn),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTurnIndicator(GameProvider game, bool isWhiteTurn) {
    final total = getDeploymentPieces().length * 2;
    final progress = game.deploymentProgress;

    return Row(
      children: [
        // Avatar joueur
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isWhiteTurn
                  ? [FantasyTheme.gold, FantasyTheme.goldLight]
                  : [FantasyTheme.purple, FantasyTheme.purpleLight],
            ),
            boxShadow: FantasyTheme.glowShadow(
              isWhiteTurn ? FantasyTheme.gold : FantasyTheme.purple,
              intensity: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              isWhiteTurn ? '♔' : '♚',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Texte
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWhiteTurn ? 'BLANCS déploient' : 'NOIRS déploient',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isWhiteTurn ? FantasyTheme.gold : FantasyTheme.purpleLight,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / total,
                  backgroundColor:
                      FantasyTheme.bgLight.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(
                    isWhiteTurn ? FantasyTheme.gold : FantasyTheme.purpleLight,
                  ),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Compteur
        Text(
          '$progress/$total',
          style: TextStyle(
            fontSize: 12,
            color: FantasyTheme.silver,
          ),
        ),
      ],
    );
  }

  Widget _buildPieceSelector(
    BuildContext context,
    GameProvider game,
    List<PieceType> pieces,
    bool isWhiteTurn,
  ) {
    // Regrouper par type pour afficher joliment
    final Map<PieceType, int> counts = {};
    for (final p in pieces) {
      counts[p] = (counts[p] ?? 0) + 1;
    }

    // Ordre d'affichage
    final order = [
      PieceType.king,
      PieceType.queen,
      PieceType.rook,
      PieceType.bishop,
      PieceType.knight,
    ];

    final displayPieces = <MapEntry<PieceType, int>>[];
    for (final type in order) {
      if (counts.containsKey(type)) {
        displayPieces.add(MapEntry(type, counts[type]!));
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in displayPieces)
          for (int i = 0; i < entry.value; i++)
            _buildPieceCard(
              context,
              game,
              entry.key,
              isWhiteTurn,
              _findIndexInList(pieces, entry.key, i),
            ),
      ],
    );
  }

  int _findIndexInList(List<PieceType> list, PieceType type, int occurrence) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i] == type) {
        if (count == occurrence) return i;
        count++;
      }
    }
    return 0;
  }

  Widget _buildPieceCard(
    BuildContext context,
    GameProvider game,
    PieceType type,
    bool isWhiteTurn,
    int index,
  ) {
    final isSelected = game.selectedDeployPiece == type &&
        game.selectedDeployPieceIndex == index;
    final piece = ChessPiece(
      type: type,
      color: isWhiteTurn ? PieceColor.white : PieceColor.black,
    );

    return GestureDetector(
      onTap: () => game.selectDeployPiece(type, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isWhiteTurn
                      ? [FantasyTheme.goldDark, FantasyTheme.gold]
                      : [FantasyTheme.purpleDark, FantasyTheme.purple],
                )
              : null,
          color: isSelected ? null : FantasyTheme.bgLight,
          border: Border.all(
            color: isSelected
                ? (isWhiteTurn ? FantasyTheme.goldLight : FantasyTheme.purpleLight)
                : FantasyTheme.purple.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? FantasyTheme.glowShadow(
                  isWhiteTurn ? FantasyTheme.gold : FantasyTheme.purple,
                  intensity: 0.7,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              piece.symbol,
              style: TextStyle(
                fontSize: 28,
                shadows: [
                  Shadow(
                    color: isSelected
                        ? (isWhiteTurn
                            ? FantasyTheme.gold
                            : FantasyTheme.purpleLight)
                        : Colors.transparent,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              piece.name,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? FantasyTheme.white : FantasyTheme.silver,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeployedPreview(
      List<ChessPiece> deployed, bool isWhiteTurn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà placées : ',
          style: TextStyle(
            fontSize: 11,
            color: FantasyTheme.silver.withValues(alpha: 0.6),
          ),
        ),
        ...deployed.map((p) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                p.symbol,
                style: TextStyle(
                  fontSize: 16,
                  color: isWhiteTurn
                      ? FantasyTheme.gold.withValues(alpha: 0.7)
                      : FantasyTheme.purpleLight.withValues(alpha: 0.7),
                ),
              ),
            )),
      ],
    );
  }

  List<ChessPiece> _getDeployedPieces(GameProvider game) {
    final row = game.currentTurn == PieceColor.white ? 7 : 0;
    final pieces = <ChessPiece>[];
    for (int col = 0; col < 8; col++) {
      final p = game.board[row][col];
      if (p != null && p.color == game.currentTurn) {
        pieces.add(p);
      }
    }
    return pieces;
  }
}
