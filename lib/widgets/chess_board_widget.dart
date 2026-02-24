// ============================================================
// WIDGET ÉCHIQUIER FANTASY
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_models.dart';
import '../services/game_provider.dart';
import '../utils/fantasy_theme.dart';

class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            final cellSize = size / 8;

            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  // Plateau
                  _buildBoard(context, game, cellSize),
                  // Highlights des cases légales
                  ..._buildLegalMoveHighlights(game, cellSize),
                  // Highlight case sélectionnée
                  if (game.selectedPosition != null)
                    _buildSelectedHighlight(game.selectedPosition!, cellSize),
                  // Highlight roi en échec
                  if (game.isCurrentKingInCheck)
                    _buildCheckHighlight(game, cellSize),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBoard(BuildContext context, GameProvider game, double cellSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final pos = Position(row, col);
        final isLight = (row + col) % 2 == 0;
        final piece = game.board[row][col];

        // Case de déploiement valide
        final isDeployRow = game.isDeploymentPhase &&
            ((game.currentTurn == PieceColor.white && row == 7) ||
                (game.currentTurn == PieceColor.black && row == 0));
        final isDeployable =
            isDeployRow && piece == null && game.selectedDeployPiece != null;

        Color squareColor;
        if (isDeployable) {
          squareColor = isLight
              ? FantasyTheme.emerald.withValues(alpha: 0.4)
              : FantasyTheme.emeraldDark.withValues(alpha: 0.6);
        } else {
          squareColor = isLight ? FantasyTheme.lightSquare : FantasyTheme.darkSquare;
        }

        return GestureDetector(
          onTap: () => _handleTap(context, game, row, col),
          child: Container(
            decoration: BoxDecoration(
              color: squareColor,
              border: isDeployable
                  ? Border.all(
                      color: FantasyTheme.emeraldGlow.withValues(alpha: 0.7),
                      width: 1,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Coordonnées
                if (col == 0)
                  Positioned(
                    top: 2,
                    left: 3,
                    child: Text(
                      '${8 - row}',
                      style: TextStyle(
                        fontSize: cellSize * 0.18,
                        color: isLight
                            ? FantasyTheme.darkSquare
                            : FantasyTheme.lightSquare,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (row == 7)
                  Positioned(
                    bottom: 2,
                    right: 3,
                    child: Text(
                      String.fromCharCode('a'.codeUnitAt(0) + col),
                      style: TextStyle(
                        fontSize: cellSize * 0.18,
                        color: isLight
                            ? FantasyTheme.darkSquare
                            : FantasyTheme.lightSquare,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Pièce
                if (piece != null)
                  Center(
                    child: _buildPiece(piece, cellSize, game, pos),
                  ),
                // Indicateur case déployable
                if (isDeployable)
                  Center(
                    child: Container(
                      width: cellSize * 0.25,
                      height: cellSize * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FantasyTheme.emeraldGlow.withValues(alpha: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: FantasyTheme.emeraldGlow.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPiece(
    ChessPiece piece,
    double cellSize,
    GameProvider game,
    Position pos,
  ) {
    final isSelected = game.selectedPosition == pos;
    final isWhite = piece.color == PieceColor.white;

    // Pièce sélectionnable en phase déploiement (pour annuler)
    final isOwnRowDeploy = game.isDeploymentPhase &&
        piece.color == game.currentTurn &&
        ((game.currentTurn == PieceColor.white && pos.row == 7) ||
            (game.currentTurn == PieceColor.black && pos.row == 0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: cellSize * (isSelected ? 0.95 : 0.85),
      height: cellSize * (isSelected ? 0.95 : 0.85),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isWhite
              ? [
                  const Color(0xFFF8F0FF),
                  FantasyTheme.whitePieceColor,
                  const Color(0xFFD4C8F0),
                ]
              : [
                  const Color(0xFF2D1F4E),
                  FantasyTheme.blackPieceColor,
                  const Color(0xFF0A0818),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: isSelected
              ? FantasyTheme.gold
              : isOwnRowDeploy
                  ? FantasyTheme.orange.withValues(alpha: 0.8)
                  : (isWhite
                      ? FantasyTheme.whitePieceBorder.withValues(alpha: 0.8)
                      : FantasyTheme.blackPieceBorder.withValues(alpha: 0.8)),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? FantasyTheme.glowShadow(FantasyTheme.gold)
            : [
                BoxShadow(
                  color: (isWhite
                          ? FantasyTheme.purpleLight
                          : FantasyTheme.purple)
                      .withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Center(
        child: Text(
          piece.symbol,
          style: TextStyle(
            fontSize: cellSize * 0.55,
            height: 1.0,
            shadows: [
              Shadow(
                color: isWhite
                    ? FantasyTheme.gold.withValues(alpha: 0.5)
                    : FantasyTheme.purple.withValues(alpha: 0.8),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLegalMoveHighlights(GameProvider game, double cellSize) {
    return game.legalMoves.map((pos) {
      final hasPiece = game.board[pos.row][pos.col] != null;
      return Positioned(
        left: pos.col * cellSize,
        top: pos.row * cellSize,
        width: cellSize,
        height: cellSize,
        child: IgnorePointer(
          child: Center(
            child: hasPiece
                ? Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: FantasyTheme.emeraldGlow.withValues(alpha: 0.9),
                        width: 3,
                      ),
                    ),
                  )
                : Container(
                    width: cellSize * 0.38,
                    height: cellSize * 0.38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FantasyTheme.emeraldGlow.withValues(alpha: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: FantasyTheme.emeraldGlow.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSelectedHighlight(Position pos, double cellSize) {
    return Positioned(
      left: pos.col * cellSize,
      top: pos.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: FantasyTheme.gold.withValues(alpha: 0.25),
            border: Border.all(
              color: FantasyTheme.gold.withValues(alpha: 0.7),
              width: 2,
            ),
            boxShadow: FantasyTheme.glowShadow(
              FantasyTheme.gold,
              intensity: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckHighlight(GameProvider game, double cellSize) {
    final kingPos = game.getKingPosition(game.currentTurn);
    if (kingPos == null) return const SizedBox.shrink();

    return Positioned(
      left: kingPos.col * cellSize,
      top: kingPos.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                FantasyTheme.red.withValues(alpha: 0.9),
                FantasyTheme.red.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: FantasyTheme.red,
              width: 2.5,
            ),
            boxShadow: FantasyTheme.glowShadow(FantasyTheme.red),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, GameProvider game, int row, int col) {
    if (game.isDeploymentPhase) {
      final pos = Position(row, col);
      final piece = game.board[row][col];

      // Si c'est une pièce déjà placée par le joueur actuel → annuler
      final ownRow = game.currentTurn == PieceColor.white ? 7 : 0;
      if (piece != null && piece.color == game.currentTurn && row == ownRow) {
        game.undoDeploy(pos);
        return;
      }

      // Sinon déployer sur cette colonne
      if (game.selectedDeployPiece != null) {
        game.deployPiece(col);
      }
    } else if (game.isPlayingPhase) {
      game.handleSquareTap(Position(row, col));
    }
  }
}
