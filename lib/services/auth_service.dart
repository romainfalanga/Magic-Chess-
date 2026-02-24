// ============================================================
// SERVICE AUTH - Inscription / Connexion Firebase
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream de l'utilisateur connecté
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  // Inscription
  static Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Vérifier que le pseudo n'est pas déjà pris
      final existing = await _db
          .collection('users')
          .where('username_lower', isEqualTo: username.toLowerCase())
          .get();
      if (existing.docs.isNotEmpty) {
        return 'Ce pseudo est déjà pris';
      }

      // Créer le compte Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le profil dans Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'username': username,
        'username_lower': username.toLowerCase(),
        'avatar': _randomAvatar(),
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'friends': [],
        'friend_requests_sent': [],
        'friend_requests_received': [],
        'created_at': FieldValue.serverTimestamp(),
        'last_seen': FieldValue.serverTimestamp(),
        'is_online': true,
      });

      return null; // succès
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'Erreur inattendue : $e';
    }
  }

  // Connexion
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Mettre à jour le statut en ligne
      await _updateOnlineStatus(true);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _updateOnlineStatus(false);
    await _auth.signOut();
  }

  // Mise à jour statut en ligne
  static Future<void> _updateOnlineStatus(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'is_online': isOnline,
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer le profil d'un utilisateur
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Récupérer le profil en temps réel
  static Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Chercher des joueurs par pseudo
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase().trim();
    final results = await _db
        .collection('users')
        .where('username_lower', isGreaterThanOrEqualTo: lower)
        .where('username_lower', isLessThan: '${lower}z')
        .limit(10)
        .get();

    return results.docs
        .where((d) => d.id != currentUser?.uid)
        .map((d) => d.data())
        .toList();
  }

  // Traductions erreurs Firebase
  static String _authError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Cet email est déjà utilisé';
      case 'invalid-email': return 'Email invalide';
      case 'weak-password': return 'Mot de passe trop faible (6 caractères min)';
      case 'user-not-found': return 'Aucun compte avec cet email';
      case 'wrong-password': return 'Mot de passe incorrect';
      case 'too-many-requests': return 'Trop de tentatives, réessaie plus tard';
      default: return 'Erreur de connexion ($code)';
    }
  }

  static String _randomAvatar() {
    const avatars = ['♔', '♕', '♗', '♘', '♖', '♙'];
    avatars.shuffle();
    return avatars.first;
  }
}
