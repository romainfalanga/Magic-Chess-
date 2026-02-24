// ============================================================
// MODÈLES DE DONNÉES - Chess Strategy
// ============================================================

enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

enum GamePhase {
  deployment, // Phase de placement des pièces
  playing,    // Partie classique
  gameOver,   // Fin de partie
}

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  String get symbol {
    switch (type) {
      case PieceType.king:   return color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:  return color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:   return color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop: return color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight: return color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:   return color == PieceColor.white ? '♙' : '♟';
    }
  }

  String get name {
    switch (type) {
      case PieceType.king:   return 'Roi';
      case PieceType.queen:  return 'Dame';
      case PieceType.rook:   return 'Tour';
      case PieceType.bishop: return 'Fou';
      case PieceType.knight: return 'Cavalier';
      case PieceType.pawn:   return 'Pion';
    }
  }

  String get shortName {
    switch (type) {
      case PieceType.king:   return 'K';
      case PieceType.queen:  return 'Q';
      case PieceType.rook:   return 'R';
      case PieceType.bishop: return 'B';
      case PieceType.knight: return 'N';
      case PieceType.pawn:   return 'P';
    }
  }
}

class Position {
  final int row; // 0-7 (0 = rangée 8 pour les noirs en haut)
  final int col; // 0-7 (0 = colonne a)

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 8 + col;

  @override
  String toString() {
    final colLetter = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rowNumber = 8 - row;
    return '$colLetter$rowNumber';
  }

  Position operator +(Position other) => Position(row + other.row, col + other.col);
}

class Move {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final bool isCastling;
  final bool isEnPassant;
  final PieceType? promotionPiece;

  const Move({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.isCastling = false,
    this.isEnPassant = false,
    this.promotionPiece,
  });
}

// Liste des pièces à déployer pour chaque joueur
List<PieceType> getDeploymentPieces() {
  return [
    PieceType.king,
    PieceType.queen,
    PieceType.rook,
    PieceType.rook,
    PieceType.bishop,
    PieceType.bishop,
    PieceType.knight,
    PieceType.knight,
  ];
}
