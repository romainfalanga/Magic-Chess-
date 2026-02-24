// ============================================================
// SERVICE AMIS - Gestion des amis et invitations
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FriendService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Envoyer une demande d'ami
  static Future<String?> sendFriendRequest(String targetUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return 'Non connecté';
    if (myUid == targetUid) return 'Vous ne pouvez pas vous ajouter vous-même';

    try {
      final myDoc = await _db.collection('users').doc(myUid).get();
      final myData = myDoc.data()!;

      final friends = List<String>.from(myData['friends'] ?? []);
      final sent = List<String>.from(myData['friend_requests_sent'] ?? []);

      if (friends.contains(targetUid)) return 'Déjà ami';
      if (sent.contains(targetUid)) return 'Demande déjà envoyée';

      // Ajouter dans ma liste "envoyées"
      await _db.collection('users').doc(myUid).update({
        'friend_requests_sent': FieldValue.arrayUnion([targetUid]),
      });

      // Ajouter dans la liste "reçues" de la cible
      await _db.collection('users').doc(targetUid).update({
        'friend_requests_received': FieldValue.arrayUnion([myUid]),
      });

      return null; // succès
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  // Accepter une demande d'ami
  static Future<void> acceptFriendRequest(String fromUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return;

    final batch = _db.batch();

    // Moi : supprimer de received, ajouter à friends
    batch.update(_db.collection('users').doc(myUid), {
      'friend_requests_received': FieldValue.arrayRemove([fromUid]),
      'friends': FieldValue.arrayUnion([fromUid]),
    });

    // Lui : supprimer de sent, ajouter à friends
    batch.update(_db.collection('users').doc(fromUid), {
      'friend_requests_sent': FieldValue.arrayRemove([myUid]),
      'friends': FieldValue.arrayUnion([myUid]),
    });

    await batch.commit();
  }

  // Refuser une demande d'ami
  static Future<void> declineFriendRequest(String fromUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return;

    await _db.collection('users').doc(myUid).update({
      'friend_requests_received': FieldValue.arrayRemove([fromUid]),
    });
    await _db.collection('users').doc(fromUid).update({
      'friend_requests_sent': FieldValue.arrayRemove([myUid]),
    });
  }

  // Supprimer un ami
  static Future<void> removeFriend(String friendUid) async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return;

    final batch = _db.batch();
    batch.update(_db.collection('users').doc(myUid), {
      'friends': FieldValue.arrayRemove([friendUid]),
    });
    batch.update(_db.collection('users').doc(friendUid), {
      'friends': FieldValue.arrayRemove([myUid]),
    });
    await batch.commit();
  }

  // Récupérer la liste des amis avec leur profil
  static Future<List<Map<String, dynamic>>> getFriends() async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return [];

    final myDoc = await _db.collection('users').doc(myUid).get();
    final friendIds = List<String>.from(myDoc.data()?['friends'] ?? []);
    if (friendIds.isEmpty) return [];

    final profiles = <Map<String, dynamic>>[];
    for (final uid in friendIds) {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) profiles.add(doc.data()!);
    }
    return profiles;
  }

  // Récupérer les demandes reçues
  static Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final myUid = AuthService.currentUser?.uid;
    if (myUid == null) return [];

    final myDoc = await _db.collection('users').doc(myUid).get();
    final requestIds =
        List<String>.from(myDoc.data()?['friend_requests_received'] ?? []);
    if (requestIds.isEmpty) return [];

    final profiles = <Map<String, dynamic>>[];
    for (final uid in requestIds) {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) profiles.add(doc.data()!);
    }
    return profiles;
  }
}
