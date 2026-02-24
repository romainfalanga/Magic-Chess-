// ============================================================
// MOTEUR D'ÉCHECS - Règles complètes
// ============================================================

import '../models/chess_models.dart';

class ChessEngine {
  // Calcule tous les mouvements légaux pour une pièce
  static List<Position> getLegalMoves(
    List<List<ChessPiece?>> board,
    Position pos,
    Position? enPassantTarget,
  ) {
    final piece = board[pos.row][pos.col];
    if (piece == null) return [];

    final rawMoves = _getRawMoves(board, pos, enPassantTarget);
    // Filtrer les mouvements qui mettraient le roi en échec
    return rawMoves.where((to) {
      final simBoard = _simulateMove(board, pos, to);
      return !isKingInCheck(simBoard, piece.color);
    }).toList();
  }

  // Mouvements bruts sans vérification d'échec
  static List<Position> _getRawMoves(
    List<List<ChessPiece?>> board,
    Position pos,
    Position? enPassantTarget,
  ) {
    final piece = board[pos.row][pos.col];
    if (piece == null) return [];

    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnMoves(board, pos, enPassantTarget);
      case PieceType.rook:
        return _getSlidingMoves(board, pos, [
          Position(-1, 0), Position(1, 0),
          Position(0, -1), Position(0, 1)
        ]);
      case PieceType.bishop:
        return _getSlidingMoves(board, pos, [
          Position(-1, -1), Position(-1, 1),
          Position(1, -1), Position(1, 1)
        ]);
      case PieceType.queen:
        return _getSlidingMoves(board, pos, [
          Position(-1, 0), Position(1, 0),
          Position(0, -1), Position(0, 1),
          Position(-1, -1), Position(-1, 1),
          Position(1, -1), Position(1, 1)
        ]);
      case PieceType.knight:
        return _getKnightMoves(board, pos);
      case PieceType.king:
        return _getKingMoves(board, pos);
    }
  }

  static List<Position> _getPawnMoves(
    List<List<ChessPiece?>> board,
    Position pos,
    Position? enPassantTarget,
  ) {
    final piece = board[pos.row][pos.col]!;
    final moves = <Position>[];
    final dir = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Avancer d'une case
    final oneStep = Position(pos.row + dir, pos.col);
    if (oneStep.isValid && board[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);
      // Avancer de deux cases depuis la position initiale
      if (pos.row == startRow) {
        final twoStep = Position(pos.row + dir * 2, pos.col);
        if (twoStep.isValid && board[twoStep.row][twoStep.col] == null) {
          moves.add(twoStep);
        }
      }
    }

    // Captures diagonales
    for (final dc in [-1, 1]) {
      final capturePos = Position(pos.row + dir, pos.col + dc);
      if (capturePos.isValid) {
        final target = board[capturePos.row][capturePos.col];
        if (target != null && target.color != piece.color) {
          moves.add(capturePos);
        }
        // En passant
        if (enPassantTarget != null && capturePos == enPassantTarget) {
          moves.add(capturePos);
        }
      }
    }

    return moves;
  }

  static List<Position> _getSlidingMoves(
    List<List<ChessPiece?>> board,
    Position pos,
    List<Position> directions,
  ) {
    final piece = board[pos.row][pos.col]!;
    final moves = <Position>[];

    for (final dir in directions) {
      var current = Position(pos.row + dir.row, pos.col + dir.col);
      while (current.isValid) {
        final target = board[current.row][current.col];
        if (target == null) {
          moves.add(current);
        } else {
          if (target.color != piece.color) moves.add(current);
          break;
        }
        current = Position(current.row + dir.row, current.col + dir.col);
      }
    }

    return moves;
  }

  static List<Position> _getKnightMoves(
    List<List<ChessPiece?>> board,
    Position pos,
  ) {
    final piece = board[pos.row][pos.col]!;
    final moves = <Position>[];
    const offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2],  [1, 2],  [2, -1],  [2, 1]
    ];

    for (final offset in offsets) {
      final target = Position(pos.row + offset[0], pos.col + offset[1]);
      if (target.isValid) {
        final t = board[target.row][target.col];
        if (t == null || t.color != piece.color) {
          moves.add(target);
        }
      }
    }

    return moves;
  }

  static List<Position> _getKingMoves(
    List<List<ChessPiece?>> board,
    Position pos,
  ) {
    final piece = board[pos.row][pos.col]!;
    final moves = <Position>[];
    const offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ];

    for (final offset in offsets) {
      final target = Position(pos.row + offset[0], pos.col + offset[1]);
      if (target.isValid) {
        final t = board[target.row][target.col];
        if (t == null || t.color != piece.color) {
          moves.add(target);
        }
      }
    }

    // Roque (vérifié séparément)
    moves.addAll(_getCastlingMoves(board, pos));

    return moves;
  }

  static List<Position> _getCastlingMoves(
    List<List<ChessPiece?>> board,
    Position kingPos,
  ) {
    final king = board[kingPos.row][kingPos.col];
    if (king == null || king.type != PieceType.king || king.hasMoved) return [];

    final moves = <Position>[];
    final row = kingPos.row;

    // Chercher les tours sur la même rangée qui n'ont pas bougé
    for (int col = 0; col < 8; col++) {
      final piece = board[row][col];
      if (piece == null || piece.type != PieceType.rook ||
          piece.color != king.color || piece.hasMoved) { continue; }

      final isKingSide = col > kingPos.col;
      final targetKingCol = isKingSide ? kingPos.col + 2 : kingPos.col - 2;

      // Vérifier que les cases entre roi et tour sont libres
      final minCol = isKingSide ? kingPos.col + 1 : targetKingCol;
      final maxCol = isKingSide ? col - 1 : kingPos.col - 1;

      bool pathClear = true;
      for (int c = minCol; c <= maxCol; c++) {
        if (board[row][c] != null) {
          pathClear = false;
          break;
        }
      }

      if (!pathClear) continue;

      // Vérifier que le roi ne passe pas par une case attaquée
      bool pathSafe = true;
      final step = isKingSide ? 1 : -1;
      for (int c = kingPos.col; c != targetKingCol + step; c += step) {
        final simBoard = _cloneBoard(board);
        simBoard[row][c] = king;
        simBoard[row][kingPos.col] = null;
        if (isKingInCheck(simBoard, king.color)) {
          pathSafe = false;
          break;
        }
      }

      if (pathSafe) {
        moves.add(Position(row, targetKingCol));
      }
    }

    return moves;
  }

  // Vérifie si le roi d'une couleur est en échec
  static bool isKingInCheck(List<List<ChessPiece?>> board, PieceColor color) {
    // Trouver la position du roi
    Position? kingPos;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          kingPos = Position(r, c);
          break;
        }
      }
      if (kingPos != null) break;
    }
    if (kingPos == null) return false;

    // Vérifier si une pièce adverse peut capturer le roi
    final opponent = color == PieceColor.white ? PieceColor.black : PieceColor.white;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == opponent) {
          final moves = _getRawMoves(board, Position(r, c), null);
          if (moves.contains(kingPos)) return true;
        }
      }
    }
    return false;
  }

  // Vérifie si un joueur est en échec et mat
  static bool isCheckmate(
    List<List<ChessPiece?>> board,
    PieceColor color,
    Position? enPassantTarget,
  ) {
    return isKingInCheck(board, color) &&
        !_hasAnyLegalMove(board, color, enPassantTarget);
  }

  // Vérifie le pat
  static bool isStalemate(
    List<List<ChessPiece?>> board,
    PieceColor color,
    Position? enPassantTarget,
  ) {
    return !isKingInCheck(board, color) &&
        !_hasAnyLegalMove(board, color, enPassantTarget);
  }

  static bool _hasAnyLegalMove(
    List<List<ChessPiece?>> board,
    PieceColor color,
    Position? enPassantTarget,
  ) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == color) {
          if (getLegalMoves(board, Position(r, c), enPassantTarget).isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Applique un mouvement sur le plateau
  static List<List<ChessPiece?>> applyMove(
    List<List<ChessPiece?>> board,
    Move move,
  ) {
    final newBoard = _cloneBoard(board);
    final piece = newBoard[move.from.row][move.from.col]!;
    final movedPiece = piece.copyWith(hasMoved: true);

    // Roque
    if (piece.type == PieceType.king &&
        (move.to.col - move.from.col).abs() == 2) {
      final row = move.from.row;
      final isKingSide = move.to.col > move.from.col;

      // Trouver la tour pour le roque
      int rookCol = -1;
      if (isKingSide) {
        for (int c = move.from.col + 1; c < 8; c++) {
          if (newBoard[row][c]?.type == PieceType.rook &&
              newBoard[row][c]?.color == piece.color) {
            rookCol = c;
            break;
          }
        }
      } else {
        for (int c = move.from.col - 1; c >= 0; c--) {
          if (newBoard[row][c]?.type == PieceType.rook &&
              newBoard[row][c]?.color == piece.color) {
            rookCol = c;
            break;
          }
        }
      }

      if (rookCol != -1) {
        final rookTargetCol = isKingSide ? move.to.col - 1 : move.to.col + 1;
        newBoard[row][rookTargetCol] = newBoard[row][rookCol]!.copyWith(hasMoved: true);
        newBoard[row][rookCol] = null;
      }
    }

    // En passant
    if (piece.type == PieceType.pawn && move.isEnPassant) {
      final capturedPawnRow = move.from.row;
      newBoard[capturedPawnRow][move.to.col] = null;
    }

    // Promotion
    if (move.promotionPiece != null) {
      newBoard[move.to.row][move.to.col] =
          ChessPiece(type: move.promotionPiece!, color: piece.color, hasMoved: true);
    } else {
      newBoard[move.to.row][move.to.col] = movedPiece;
    }

    newBoard[move.from.row][move.from.col] = null;
    return newBoard;
  }

  // Calcule la cible en passant après un mouvement de pion de 2 cases
  static Position? getEnPassantTarget(
    List<List<ChessPiece?>> board,
    Move move,
  ) {
    final piece = board[move.from.row][move.from.col];
    if (piece == null || piece.type != PieceType.pawn) return null;
    if ((move.to.row - move.from.row).abs() == 2) {
      return Position(
        (move.from.row + move.to.row) ~/ 2,
        move.from.col,
      );
    }
    return null;
  }

  // Clone le plateau
  static List<List<ChessPiece?>> _cloneBoard(List<List<ChessPiece?>> board) {
    return List.generate(8, (r) => List.generate(8, (c) => board[r][c]));
  }

  // Simule un mouvement pour vérifier l'échec
  static List<List<ChessPiece?>> _simulateMove(
    List<List<ChessPiece?>> board,
    Position from,
    Position to,
  ) {
    final newBoard = _cloneBoard(board);
    final piece = newBoard[from.row][from.col]!;
    newBoard[to.row][to.col] = piece.copyWith(hasMoved: true);
    newBoard[from.row][from.col] = null;
    return newBoard;
  }

  // Vérifie si un pion est en promotion
  static bool isPawnPromotion(List<List<ChessPiece?>> board, Position to) {
    final piece = board[to.row][to.col];
    return piece != null &&
        piece.type == PieceType.pawn &&
        (to.row == 0 || to.row == 7);
  }

  // Insuffisance de matériel (nulle)
  static bool isInsufficientMaterial(List<List<ChessPiece?>> board) {
    final pieces = <ChessPiece>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] != null) pieces.add(board[r][c]!);
      }
    }

    if (pieces.length <= 2) return true; // Roi vs Roi
    if (pieces.length == 3) {
      return pieces.any((p) =>
          p.type == PieceType.bishop || p.type == PieceType.knight);
    }
    return false;
  }
}
