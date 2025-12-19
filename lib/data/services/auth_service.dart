import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import '../../modules/auth/pairing_view.dart';

/// AuthService - Handles Firebase Authentication
/// Firebase Auth automatically persists sessions - no SharedPreferences needed
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user reactive variable
  final Rx<User?> currentUser = Rx<User?>(null);

  // Current user model from Firestore
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  // Loading state
  final RxBool isLoading = false.obs;

  // Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  // Get current user ID
  String? get userId => currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    currentUser.bindStream(_auth.authStateChanges());
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create initial user document in Firestore
        final dbService = Get.find<DatabaseService>();
        await dbService.createUser(credential.user!.uid, email);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendaftar: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal masuk: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      userModel.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal keluar: $e');
    }
  }

  /// Load user model from Firestore
  Future<UserModel?> loadUserModel() async {
    if (userId == null) return null;

    try {
      final dbService = Get.find<DatabaseService>();
      final model = await dbService.getUser(userId!);
      userModel.value = model;
      return model;
    } catch (e) {
      return null;
    }
  }

  /// Check authentication status and return route
  /// Returns: 'login', 'setup', 'pairing', or 'dashboard'
  Future<String> checkAuthStatus() async {
    // 1. Check if user is logged in
    if (currentUser.value == null) {
      return 'login';
    }

    // 2. Load user model from Firestore
    final model = await loadUserModel();

    // 3. Check if profile is complete
    if (model == null || !model.hasCompletedProfile) {
      return 'setup';
    }

    // 4. Check if user is paired
    if (!model.isPaired) {
      return 'pairing';
    }

    // 5. All complete
    return 'dashboard';
  }

  /// Unpair/disconnect couple relationship (Soft Delete)
  /// 1. Archives couple data to archived_couples collection
  /// 2. Detaches both users (clears partnerId and coupleId)
  /// 3. Deletes original couple document
  /// 4. Navigates to PairingView
  Future<void> unpairCouple() async {
    try {
      isLoading.value = true;

      final uid = userId;
      if (uid == null) {
        Get.snackbar('Error', 'User tidak ditemukan');
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // Get current user data
      final currentUserData = userModel.value;
      if (currentUserData == null) {
        Get.snackbar('Error', 'Data user tidak ditemukan');
        return;
      }

      final coupleId = currentUserData.coupleId;
      final partnerId = currentUserData.partnerId;

      if (coupleId == null || coupleId.isEmpty) {
        Get.snackbar('Error', 'Tidak ada hubungan yang terhubung');
        return;
      }

      // === STEP 1: Archive couple data ===
      final coupleDoc = await firestore
          .collection('couples')
          .doc(coupleId)
          .get();
      if (coupleDoc.exists) {
        final coupleData = coupleDoc.data() ?? {};
        // Add archive metadata
        coupleData['archivedAt'] = FieldValue.serverTimestamp();
        coupleData['archivedBy'] = uid;
        coupleData['originalCoupleId'] = coupleId;

        // Save to archived_couples collection
        await firestore.collection('archived_couples').add(coupleData);
      }

      // === STEP 2: Detach current user ===
      await firestore.collection('users').doc(uid).update({
        'partnerId': null,
        'coupleId': null,
      });

      // === STEP 3: Detach partner (if exists) ===
      if (partnerId != null && partnerId.isNotEmpty) {
        await firestore.collection('users').doc(partnerId).update({
          'partnerId': null,
          'coupleId': null,
        });
      }

      // === STEP 4: Delete original couple document ===
      await firestore.collection('couples').doc(coupleId).delete();

      // Clear local user model
      userModel.value = null;

      // === STEP 5: Navigate to Pairing View ===
      Get.offAll(() => const PairingView());

      Get.snackbar(
        'Berhasil',
        'Hubungan telah diputuskan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal memutuskan hubungan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'Password terlalu lemah';
        break;
      case 'email-already-in-use':
        message = 'Email sudah terdaftar';
        break;
      case 'user-not-found':
        message = 'User tidak ditemukan';
        break;
      case 'wrong-password':
        message = 'Password salah';
        break;
      case 'invalid-email':
        message = 'Email tidak valid';
        break;
      case 'invalid-credential':
        message = 'Email atau password salah';
        break;
      default:
        message = e.message ?? 'Terjadi kesalahan';
    }
    Get.snackbar('Error', message);
  }
}
