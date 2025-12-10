import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// DatabaseService - Handles Cloud Firestore operations
class DatabaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get couplesCollection => _firestore.collection('couples');
  CollectionReference get pairingCodesCollection =>
      _firestore.collection('pairing_codes');

  // ============ USER METHODS ============

  /// Create initial user document
  Future<void> createUser(String uid, String email) async {
    try {
      await usersCollection.doc(uid).set({
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat user: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    required DateTime birthday,
  }) async {
    try {
      await usersCollection.doc(uid).update({
        'name': name,
        'username': username,
        'birthday': birthday.toIso8601String(),
      });
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan profil: $e');
      return false;
    }
  }

  /// Stream user document changes
  Stream<UserModel?> streamUser(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // ============ PAIRING CODE METHODS ============

  /// Generate unique 6-character pairing code
  String _generatePairingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid confusing chars
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create pairing code for user
  Future<String?> createPairingCode(String creatorUid) async {
    try {
      // Generate unique code
      String code = _generatePairingCode();

      // Check if code exists, regenerate if needed
      var exists = await pairingCodesCollection.doc(code).get();
      int attempts = 0;
      while (exists.exists && attempts < 10) {
        code = _generatePairingCode();
        exists = await pairingCodesCollection.doc(code).get();
        attempts++;
      }

      // Save code
      await pairingCodesCollection.doc(code).set({
        'creatorUid': creatorUid,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return code;
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat kode: $e');
      return null;
    }
  }

  /// Find pairing code and get creator UID
  Future<String?> findPairingCode(String code) async {
    try {
      final doc = await pairingCodesCollection.doc(code.toUpperCase()).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['creatorUid'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete pairing code after successful pairing
  Future<void> deletePairingCode(String code) async {
    try {
      await pairingCodesCollection.doc(code.toUpperCase()).delete();
    } catch (e) {
      // Silent fail
    }
  }

  // ============ COUPLE METHODS ============

  /// Connect two users as partners
  Future<bool> connectPartners(String uid1, String uid2) async {
    try {
      // Create couple document
      final coupleDoc = await couplesCollection.add({
        'user1': uid1,
        'user2': uid2,
        'createdAt': DateTime.now().toIso8601String(),
        'streakCount': 0,
        'lastInteraction': null,
      });

      final coupleId = coupleDoc.id;

      // Update both users
      await usersCollection.doc(uid1).update({
        'partnerId': uid2,
        'coupleId': coupleId,
      });

      await usersCollection.doc(uid2).update({
        'partnerId': uid1,
        'coupleId': coupleId,
      });

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghubungkan: $e');
      return false;
    }
  }

  /// Get couple document
  Future<DocumentSnapshot?> getCouple(String coupleId) async {
    try {
      return await couplesCollection.doc(coupleId).get();
    } catch (e) {
      return null;
    }
  }

  /// Stream couple document changes
  Stream<DocumentSnapshot> streamCouple(String coupleId) {
    return couplesCollection.doc(coupleId).snapshots();
  }
}
