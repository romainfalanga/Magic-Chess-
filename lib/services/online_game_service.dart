// ============================================================
// SERVICE PARTIE EN LIGNE - Firestore realtime
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chess_models.dart';
import 'auth_service.dart';

class OnlineGameService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer une invitation de partie
  static Future<String?> inviteFriend(String friendUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return null;

    final myProfile = await AuthService.getUserProfile(myUid);
    final inviteRef = await _db.collection('game_invites').add({
      'from_uid': myUid,
      'from_username': myProfile?['username'] ?? 'Joueur',
      'to_uid': friendUid,
      'status': 'pending', // pending / accepted / declined
      'created_at': FieldValue.serverTimestamp(),
    });
    return inviteRef.id;
  }

  // Écouter les invitations reçues
  static Stream<QuerySnapshot> getIncomingInvites() {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return const Stream.empty();
    return _db
        .collection('game_invites')
        .where('to_uid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Accepter une invitation → créer la partie
  static Future<String?> acceptInvite(String inviteId, String fromUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return null;

    // Mettre à jour l'invitation
    await _db.collection('game_invites').doc(inviteId).update({
      'status': 'accepted',
    });

    // Créer la partie
    final gameRef = await _db.collection('games').add({
      'white_uid': fromUid,
      'black_uid': myUid,
      'phase': 'deployment',
      'current_turn': 'white',
      'board': _emptyBoardJson(),
      'white_pieces_to_deploy': _deploymentPiecesJson(),
      'black_pieces_to_deploy': _deploymentPiecesJson(),
      'en_passant_target': null,
      'move_history': [],
      'status': 'active', // active / finished
      'result': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Mettre à jour l'invitation avec l'ID de la partie
    await _db.collection('game_invites').doc(inviteId).update({
      'game_id': gameRef.id,
    });

    return gameRef.id;
  }

  // Refuser une invitation
  static Future<void> declineInvite(String inviteId) async {
    await _db.collection('game_invites').doc(inviteId).update({
      'status': 'declined',
    });
  }

  // Écouter l'état d'une partie en temps réel
  static Stream<DocumentSnapshot> watchGame(String gameId) {
    return _db.collection('games').doc(gameId).snapshots();
  }

  // Envoyer un mouvement de déploiement
  static Future<void> sendDeployMove({
    required String gameId,
    required String color,
    required int col,
    required String pieceType,
    required List<String> remainingPieces,
    required List<List<String?>> boardState,
    required String nextTurn,
    required String newPhase,
  }) async {
    await _db.collection('games').doc(gameId).update({
      'board': _boardToJson(boardState),
      '${color}_pieces_to_deploy': remainingPieces,
      'current_turn': nextTurn,
      'phase': newPhase,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Envoyer un mouvement classique
  static Future<void> sendMove({
    required String gameId,
    required String color,
    required Map<String, dynamic> moveData,
    required List<List<String?>> boardState,
    required String nextTurn,
    required String? enPassantTarget,
    required String? result,
  }) async {
    final updates = <String, dynamic>{
      'board': _boardToJson(boardState),
      'current_turn': nextTurn,
      'en_passant_target': enPassantTarget,
      'updated_at': FieldValue.serverTimestamp(),
      'move_history': FieldValue.arrayUnion([moveData]),
    };

    if (result != null) {
      updates['status'] = 'finished';
      updates['result'] = result;
    }

    await _db.collection('games').doc(gameId).update(updates);
  }

  // Mes parties actives
  static Stream<QuerySnapshot> getActiveGames() {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return const Stream.empty();
    return _db
        .collection('games')
        .where('status', isEqualTo: 'active')
        .where('white_uid', isEqualTo: myUid)
        .snapshots();
  }

  // Board vide en JSON
  static List<List<String?>> _emptyBoardJson() {
    return List.generate(8, (r) => List.generate(8, (c) {
      if (r == 1) return 'bp'; // pions noirs
      if (r == 6) return 'wp'; // pions blancs
      return null;
    }));
  }

  static List<List<String?>> _boardToJson(List<List<String?>> board) {
    return board;
  }

  static List<String> _deploymentPiecesJson() {
    return ['k', 'q', 'r', 'r', 'b', 'b', 'n', 'n'];
  }

  // Convertir une pièce en string
  static String pieceToCode(ChessPiece piece) {
    final colorCode = piece.color == PieceColor.white ? 'w' : 'b';
    final typeCode = piece.shortName.toLowerCase();
    return '$colorCode$typeCode';
  }

  // Convertir un string en pièce
  static ChessPiece? codeTopiece(String? code) {
    if (code == null || code.length < 2) return null;
    final color = code[0] == 'w' ? PieceColor.white : PieceColor.black;
    PieceType type;
    switch (code[1]) {
      case 'k': type = PieceType.king; break;
      case 'q': type = PieceType.queen; break;
      case 'r': type = PieceType.rook; break;
      case 'b': type = PieceType.bishop; break;
      case 'n': type = PieceType.knight; break;
      case 'p': type = PieceType.pawn; break;
      default: return null;
    }
    return ChessPiece(type: type, color: color);
  }
}
