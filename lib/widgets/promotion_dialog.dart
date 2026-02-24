// ============================================================
// DIALOG DE PROMOTION
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_models.dart';
import '../services/game_provider.dart';
import '../utils/fantasy_theme.dart';

class PromotionDialog extends StatelessWidget {
  const PromotionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.pendingPromotion == null) return const SizedBox.shrink();

        final isWhite = game.board[game.pendingPromotion!.row]
                [game.pendingPromotion!.col]?.color ==
            PieceColor.white;

        final pieces = [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight,
        ];

        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: FantasyTheme.cardDecoration(
                borderColor: FantasyTheme.gold,
                borderWidth: 2,
                borderRadius: 20,
                gradientColors: [FantasyTheme.bgMedium, FantasyTheme.bgDark],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✨ Promotion !',
                    style: FantasyTheme.titleStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez la pièce',
                    style: FantasyTheme.subtitleStyle,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: pieces
                        .map((type) => _buildChoice(context, game, type, isWhite))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoice(
    BuildContext context,
    GameProvider game,
    PieceType type,
    bool isWhite,
  ) {
    final piece = ChessPiece(
      type: type,
      color: isWhite ? PieceColor.white : PieceColor.black,
    );

    return GestureDetector(
      onTap: () => game.promote(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 64,
        height: 72,
        decoration: FantasyTheme.cardDecoration(
          borderColor: isWhite
              ? FantasyTheme.gold.withValues(alpha: 0.6)
              : FantasyTheme.purple.withValues(alpha: 0.6),
          borderRadius: 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(piece.symbol, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              piece.name,
              style: TextStyle(
                fontSize: 10,
                color: FantasyTheme.silver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
