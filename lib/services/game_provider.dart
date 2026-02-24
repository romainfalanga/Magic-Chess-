// ============================================================
// GAME PROVIDER - État global du jeu
// ============================================================

import 'package:flutter/foundation.dart';
import '../models/chess_models.dart';
import '../services/chess_engine.dart';

class GameProvider extends ChangeNotifier {
  // Plateau 8x8
  List<List<ChessPiece?>> _board = List.generate(8, (_) => List.filled(8, null));

  // Phase de jeu
  GamePhase _phase = GamePhase.deployment;

  // Tour actuel
  PieceColor _currentTurn = PieceColor.white;

  // Pièces restantes à déployer
  List<PieceType> _whitePiecesToDeploy = getDeploymentPieces();
  List<PieceType> _blackPiecesToDeploy = getDeploymentPieces();

  // Pièce sélectionnée pour le déploiement
  PieceType? _selectedDeployPiece;
  int? _selectedDeployPieceIndex;

  // Pièce sélectionnée pour le mouvement
  Position? _selectedPosition;
  List<Position> _legalMoves = [];

  // En passant
  Position? _enPassantTarget;

  // Historique des mouvements
  final List<Move> _moveHistory = [];

  // Résultat de la partie
  String? _gameResult;

  // Promotion en attente
  Position? _pendingPromotion;

  // Getters
  List<List<ChessPiece?>> get board => _board;
  GamePhase get phase => _phase;
  PieceColor get currentTurn => _currentTurn;
  List<PieceType> get whitePiecesToDeploy => _whitePiecesToDeploy;
  List<PieceType> get blackPiecesToDeploy => _blackPiecesToDeploy;
  PieceType? get selectedDeployPiece => _selectedDeployPiece;
  int? get selectedDeployPieceIndex => _selectedDeployPieceIndex;
  Position? get selectedPosition => _selectedPosition;
  List<Position> get legalMoves => _legalMoves;
  Position? get enPassantTarget => _enPassantTarget;
  List<Move> get moveHistory => _moveHistory;
  String? get gameResult => _gameResult;
  Position? get pendingPromotion => _pendingPromotion;

  bool get isWhiteTurn => _currentTurn == PieceColor.white;
  bool get isDeploymentPhase => _phase == GamePhase.deployment;
  bool get isPlayingPhase => _phase == GamePhase.playing;
  bool get isGameOver => _phase == GamePhase.gameOver;

  List<PieceType> get currentPlayerPiecesToDeploy =>
      _currentTurn == PieceColor.white ? _whitePiecesToDeploy : _blackPiecesToDeploy;

  int get deploymentProgress {
    final total = getDeploymentPieces().length * 2; // 16 pièces au total
    final remaining = _whitePiecesToDeploy.length + _blackPiecesToDeploy.length;
    return total - remaining;
  }

  // Initialisation du jeu
  void initGame() {
    _board = List.generate(8, (_) => List.filled(8, null));
    _phase = GamePhase.deployment;
    _currentTurn = PieceColor.white;
    _whitePiecesToDeploy = getDeploymentPieces();
    _blackPiecesToDeploy = getDeploymentPieces();
    _selectedDeployPiece = null;
    _selectedDeployPieceIndex = null;
    _selectedPosition = null;
    _legalMoves = [];
    _enPassantTarget = null;
    _moveHistory.clear();
    _gameResult = null;
    _pendingPromotion = null;

    // Placer les pions
    for (int col = 0; col < 8; col++) {
      _board[6][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
      _board[1][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
    }

    notifyListeners();
  }

  // ============================================================
  // PHASE DE DÉPLOIEMENT
  // ============================================================

  // Sélectionner une pièce à déployer
  void selectDeployPiece(PieceType type, int index) {
    if (_phase != GamePhase.deployment) return;
    if (_selectedDeployPiece == type && _selectedDeployPieceIndex == index) {
      // Désélectionner
      _selectedDeployPiece = null;
      _selectedDeployPieceIndex = null;
    } else {
      _selectedDeployPiece = type;
      _selectedDeployPieceIndex = index;
    }
    notifyListeners();
  }

  // Déployer une pièce sur une case de la première rangée
  bool deployPiece(int col) {
    if (_phase != GamePhase.deployment) return false;
    if (_selectedDeployPiece == null) return false;

    final row = _currentTurn == PieceColor.white ? 7 : 0;

    // Vérifier que la case est libre
    if (_board[row][col] != null) return false;

    // Placer la pièce
    _board[row][col] = ChessPiece(
      type: _selectedDeployPiece!,
      color: _currentTurn,
    );

    // Retirer la pièce de la liste à déployer
    if (_currentTurn == PieceColor.white) {
      _whitePiecesToDeploy.removeAt(_selectedDeployPieceIndex!);
    } else {
      _blackPiecesToDeploy.removeAt(_selectedDeployPieceIndex!);
    }

    _selectedDeployPiece = null;
    _selectedDeployPieceIndex = null;

    // Vérifier si tous les joueurs ont déployé toutes leurs pièces
    if (_whitePiecesToDeploy.isEmpty && _blackPiecesToDeploy.isEmpty) {
      _phase = GamePhase.playing;
      _currentTurn = PieceColor.white; // Les blancs commencent
      notifyListeners();
      return true;
    }

    // Changer de tour
    _currentTurn = _currentTurn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    notifyListeners();
    return true;
  }

  // Annuler le déploiement (retirer une pièce déjà placée)
  void undoDeploy(Position pos) {
    if (_phase != GamePhase.deployment) return;

    final piece = _board[pos.row][pos.col];
    if (piece == null || piece.color != _currentTurn) return;

    // On ne peut annuler que si c'est sa propre rangée
    final ownRow = _currentTurn == PieceColor.white ? 7 : 0;
    if (pos.row != ownRow) return;

    _board[pos.row][pos.col] = null;

    if (_currentTurn == PieceColor.white) {
      _whitePiecesToDeploy.add(piece.type);
    } else {
      _blackPiecesToDeploy.add(piece.type);
    }

    notifyListeners();
  }

  // ============================================================
  // PHASE DE JEU
  // ============================================================

  // Sélectionner/déplacer une pièce
  void handleSquareTap(Position pos) {
    if (_phase != GamePhase.playing) return;
    if (_pendingPromotion != null) return;

    final piece = _board[pos.row][pos.col];

    // Si une pièce est déjà sélectionnée
    if (_selectedPosition != null) {
      // Essayer de se déplacer vers la case tapée
      if (_legalMoves.contains(pos)) {
        _executeMove(_selectedPosition!, pos);
        return;
      }

      // Sélectionner une autre pièce du même camp
      if (piece != null && piece.color == _currentTurn) {
        _selectPiece(pos);
        return;
      }

      // Désélectionner
      _selectedPosition = null;
      _legalMoves = [];
      notifyListeners();
      return;
    }

    // Sélectionner une pièce
    if (piece != null && piece.color == _currentTurn) {
      _selectPiece(pos);
    }
  }

  void _selectPiece(Position pos) {
    _selectedPosition = pos;
    _legalMoves = ChessEngine.getLegalMoves(_board, pos, _enPassantTarget);
    notifyListeners();
  }

  void _executeMove(Position from, Position to) {
    final piece = _board[from.row][from.col]!;
    final capturedPiece = _board[to.row][to.col];

    // Déterminer si c'est une prise en passant
    final isEnPassant = piece.type == PieceType.pawn &&
        _enPassantTarget != null &&
        to == _enPassantTarget;

    final move = Move(
      from: from,
      to: to,
      capturedPiece: capturedPiece,
      isCastling: piece.type == PieceType.king && (to.col - from.col).abs() == 2,
      isEnPassant: isEnPassant,
    );

    // Calculer la nouvelle cible en passant
    final newEnPassant = ChessEngine.getEnPassantTarget(_board, move);

    // Appliquer le mouvement
    final newBoard = ChessEngine.applyMove(_board, move);

    // Vérifier promotion
    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      _board = newBoard;
      _enPassantTarget = newEnPassant;
      _pendingPromotion = to;
      _selectedPosition = null;
      _legalMoves = [];
      _moveHistory.add(move);
      notifyListeners();
      return;
    }

    _board = newBoard;
    _enPassantTarget = newEnPassant;
    _moveHistory.add(move);
    _selectedPosition = null;
    _legalMoves = [];

    // Changer de tour
    _currentTurn = _currentTurn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    _checkGameEnd();
    notifyListeners();
  }

  // Promotion
  void promote(PieceType pieceType) {
    if (_pendingPromotion == null) return;

    final pos = _pendingPromotion!;
    final piece = _board[pos.row][pos.col]!;
    _board[pos.row][pos.col] = ChessPiece(
      type: pieceType,
      color: piece.color,
      hasMoved: true,
    );

    _pendingPromotion = null;
    _currentTurn = _currentTurn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    _checkGameEnd();
    notifyListeners();
  }

  void _checkGameEnd() {
    final opponent = _currentTurn;

    if (ChessEngine.isCheckmate(_board, opponent, _enPassantTarget)) {
      _phase = GamePhase.gameOver;
      final winner = opponent == PieceColor.white ? 'Noirs' : 'Blancs';
      _gameResult = 'Échec et mat ! Les $winner gagnent !';
    } else if (ChessEngine.isStalemate(_board, opponent, _enPassantTarget)) {
      _phase = GamePhase.gameOver;
      _gameResult = 'Pat ! Partie nulle !';
    } else if (ChessEngine.isInsufficientMaterial(_board)) {
      _phase = GamePhase.gameOver;
      _gameResult = 'Matériel insuffisant. Partie nulle !';
    }
  }

  // Vérifier si le roi actuel est en échec
  bool get isCurrentKingInCheck =>
      _phase == GamePhase.playing &&
      ChessEngine.isKingInCheck(_board, _currentTurn);

  // Trouver la position du roi
  Position? getKingPosition(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          return Position(r, c);
        }
      }
    }
    return null;
  }

  // Abandonner la partie
  void resign() {
    if (_phase != GamePhase.playing) return;
    final winner = _currentTurn == PieceColor.white ? 'Noirs' : 'Blancs';
    _phase = GamePhase.gameOver;
    _gameResult = 'Abandon ! Les $winner gagnent !';
    notifyListeners();
  }

  // Nouvelle partie
  void newGame() {
    initGame();
  }
}
