import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/couple_model.dart';
import '../models/savings_goal.dart';
import '../models/journey_event.dart';

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

  /// Create pairing code for user with anniversary date
  Future<String?> createPairingCode(
    String creatorUid,
    DateTime anniversaryDate,
  ) async {
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

      // Save code with anniversary date
      await pairingCodesCollection.doc(code).set({
        'creatorUid': creatorUid,
        'createdAt': DateTime.now().toIso8601String(),
        'anniversaryDate': Timestamp.fromDate(anniversaryDate),
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

  /// Connect two users as partners using transaction (RACE CONDITION FIX)
  /// This method atomically verifies the code exists, creates the couple, and deletes the code
  Future<bool> connectPartnersWithCode(String myUid, String code) async {
    try {
      final upperCode = code.toUpperCase();

      return await _firestore.runTransaction<bool>((transaction) async {
        // 1. Get and verify the pairing code still exists (atomic read)
        final codeDoc = await transaction.get(
          pairingCodesCollection.doc(upperCode),
        );

        if (!codeDoc.exists) {
          throw Exception('Kode sudah tidak valid atau sudah digunakan');
        }

        final codeData = codeDoc.data() as Map<String, dynamic>;
        final creatorUid = codeData['creatorUid'] as String?;

        // NEW: Get anniversary date from pairing code
        final anniversaryTimestamp = codeData['anniversaryDate'] as Timestamp?;
        final anniversaryDate =
            anniversaryTimestamp?.toDate() ?? DateTime.now();

        if (creatorUid == null) {
          throw Exception('Kode tidak valid');
        }

        if (creatorUid == myUid) {
          throw Exception('Tidak bisa pairing dengan diri sendiri');
        }

        // 2. Create couple document (new reference for transaction)
        final coupleDocRef = couplesCollection.doc();
        final coupleId = coupleDocRef.id;

        transaction.set(coupleDocRef, {
          'userIds': [myUid, creatorUid],
          'user1': creatorUid,
          'user2': myUid,
          'createdAt': FieldValue.serverTimestamp(),
          // NEW: Use anniversary date from pairing code as startDate
          'startDate': Timestamp.fromDate(anniversaryDate),
          'streak': 0,
          'lastCheckIn': null,
          'totalXP': 0,
          'petMood': 'idle',
          'petName': 'Mochi',
          'totalAssets': 0.0,
          // NEW: Streak Protect
          'streakProtects': 2,
          'lastProtectResetMonth': DateTime.now().month,
          // NEW: Daily Quest
          'dailyQuestProgress': {'savings': 0, 'journey': 0, 'interaction': 0},
          'lastQuestResetDate': DateTime.now().toIso8601String(),
          // NEW: Weekly Challenge (will be set by initWeeklyChallenge)
          'weeklyChallenge': null,
          // NEW: Badge Progress
          'badgeProgress': {},
        });

        // 3. Update both users to link to couple
        transaction.update(usersCollection.doc(myUid), {
          'partnerId': creatorUid,
          'coupleId': coupleId,
        });

        transaction.update(usersCollection.doc(creatorUid), {
          'partnerId': myUid,
          'coupleId': coupleId,
        });

        // 4. Delete the pairing code (atomically, prevents reuse)
        transaction.delete(codeDoc.reference);

        return true;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Update anniversary/start date for a couple
  Future<bool> updateAnniversaryDate(String coupleId, DateTime newDate) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'startDate': Timestamp.fromDate(newDate),
      });
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah tanggal: $e');
      return false;
    }
  }

  /// Legacy method - kept for backward compatibility
  @Deprecated('Use connectPartnersWithCode instead to prevent race conditions')
  Future<bool> connectPartners(String uid1, String uid2) async {
    try {
      // Create couple document with all required fields
      final coupleDoc = await couplesCollection.add({
        'userIds': [uid1, uid2],
        'user1': uid1,
        'user2': uid2,
        'createdAt': FieldValue.serverTimestamp(),
        'startDate': FieldValue.serverTimestamp(),
        'streak': 0,
        'lastCheckIn': null,
        'totalXP': 0,
        'petMood': 'idle',
        'petName': 'Mochi',
        'totalAssets': 0.0,
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

  /// Stream couple data (Real-time)
  Stream<CoupleModel?> streamCoupleData(String coupleId) {
    return couplesCollection.doc(coupleId).snapshots().map((doc) {
      if (doc.exists) {
        return CoupleModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Get couple document (one-time)
  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (doc.exists) {
        return CoupleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update pet mood
  Future<void> updatePetMood(String coupleId, String mood) async {
    try {
      await couplesCollection.doc(coupleId).update({'petMood': mood});
    } catch (e) {
      Get.snackbar('Error', 'Gagal update mood: $e');
    }
  }

  /// Update pet name
  Future<void> updatePetName(String coupleId, String name) async {
    try {
      await couplesCollection.doc(coupleId).update({'petName': name});
    } catch (e) {
      Get.snackbar('Error', 'Gagal update nama pet: $e');
    }
  }

  /// Perform daily check-in
  Future<bool> performCheckIn(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final lastCheckIn = data['lastCheckIn'] != null
          ? (data['lastCheckIn'] is Timestamp
                ? (data['lastCheckIn'] as Timestamp).toDate()
                : DateTime.tryParse(data['lastCheckIn']))
          : null;
      final currentStreak = data['streak'] ?? 0;
      final currentXP = data['totalXP'] ?? 0;

      final now = DateTime.now();

      // Check if already checked in today
      if (lastCheckIn != null &&
          lastCheckIn.year == now.year &&
          lastCheckIn.month == now.month &&
          lastCheckIn.day == now.day) {
        Get.snackbar('Info', 'Sudah check-in hari ini! 🎉');
        return false;
      }

      // Check if streak should reset (missed a day)
      int newStreak = currentStreak + 1;
      if (lastCheckIn != null) {
        final daysSinceLastCheckIn = now.difference(lastCheckIn).inDays;
        if (daysSinceLastCheckIn > 1) {
          newStreak = 1; // Reset streak
        }
      }

      // Update streak, lastCheckIn, XP, and pet mood
      await couplesCollection.doc(coupleId).update({
        'streak': newStreak,
        'lastCheckIn': FieldValue.serverTimestamp(),
        'totalXP': currentXP + 10,
        'petMood': 'idle', // Happy after check-in
      });

      Get.snackbar('🎉 Check-in Berhasil!', '+10 XP | Streak: $newStreak hari');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal check-in: $e');
      return false;
    }
  }

  /// Feed pet (change mood to eating)
  Future<void> feedPet(String coupleId) async {
    try {
      await couplesCollection.doc(coupleId).update({'petMood': 'eating'});

      // Reset to idle after 3 seconds
      Future.delayed(const Duration(seconds: 3), () async {
        await couplesCollection.doc(coupleId).update({'petMood': 'idle'});
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memberi makan: $e');
    }
  }

  /// Add XP to couple
  Future<void> addXP(String coupleId, int xp) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'totalXP': FieldValue.increment(xp),
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Add to total assets (savings)
  Future<void> addToAssets(String coupleId, double amount) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'totalAssets': FieldValue.increment(amount),
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Poke partner (send notification simulation)
  Future<void> pokePartner(String partnerUid) async {
    try {
      // For now, just update a field to trigger notification
      // In real app, use Firebase Cloud Messaging
      await usersCollection.doc(partnerUid).update({
        'lastPokedAt': FieldValue.serverTimestamp(),
        'lastPokedBy': 'partner', // Could be the actual UID
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Stream couple document changes (legacy)
  Stream<DocumentSnapshot> streamCouple(String coupleId) {
    return couplesCollection.doc(coupleId).snapshots();
  }

  // ============ FINANCE / GOALS METHODS ============

  /// Get goals subcollection reference
  CollectionReference _goalsCollection(String coupleId) {
    return couplesCollection.doc(coupleId).collection('goals');
  }

  /// Stream all savings goals for a couple
  Stream<List<SavingsGoal>> streamGoals(String coupleId) {
    return _goalsCollection(
      coupleId,
    ).orderBy('createdDate', descending: false).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SavingsGoal.fromFirestore(doc))
          .toList();
    });
  }

  /// Add new savings goal
  Future<String?> addGoal(String coupleId, SavingsGoal goal) async {
    try {
      final docRef = await _goalsCollection(coupleId).add(goal.toMap());
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambah goal: $e');
      return null;
    }
  }

  /// Update goal amount (with totalAssets hook)
  Future<void> updateGoalAmount(
    String coupleId,
    String goalId,
    double newAmount, {
    double? addedAmount,
  }) async {
    try {
      await _goalsCollection(
        coupleId,
      ).doc(goalId).update({'currentAmount': newAmount});

      // Hook: Update totalAssets di parent couple document
      if (addedAmount != null && addedAmount > 0) {
        await addToAssets(coupleId, addedAmount);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal update saldo: $e');
    }
  }

  /// Toggle goal highlight status
  Future<void> toggleGoalHighlight(
    String coupleId,
    String goalId,
    bool isHighlighted,
  ) async {
    try {
      await _goalsCollection(
        coupleId,
      ).doc(goalId).update({'isHighlighted': isHighlighted});
    } catch (e) {
      Get.snackbar('Error', 'Gagal update highlight: $e');
    }
  }

  /// Mark goal as completed
  Future<void> completeGoal(String coupleId, String goalId) async {
    try {
      await _goalsCollection(coupleId).doc(goalId).update({
        'isCompleted': true,
        'isHighlighted': false,
        'completedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyelesaikan goal: $e');
    }
  }

  /// Delete goal
  Future<void> deleteGoal(String coupleId, String goalId) async {
    try {
      await _goalsCollection(coupleId).doc(goalId).delete();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus goal: $e');
    }
  }

  // ============ JOURNEY / EVENTS METHODS ============

  /// Get events subcollection reference
  CollectionReference _eventsCollection(String coupleId) {
    return couplesCollection.doc(coupleId).collection('events');
  }

  /// Stream all journey events for a couple
  Stream<List<JourneyEvent>> streamEvents(String coupleId) {
    return _eventsCollection(
      coupleId,
    ).orderBy('date', descending: false).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => JourneyEvent.fromFirestore(doc))
          .toList();
    });
  }

  /// Add new journey event
  Future<String?> addJourneyEvent(String coupleId, JourneyEvent event) async {
    try {
      final docRef = await _eventsCollection(coupleId).add(event.toMap());
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambah event: $e');
      return null;
    }
  }

  /// Delete journey event
  Future<void> deleteJourneyEvent(String coupleId, String eventId) async {
    try {
      await _eventsCollection(coupleId).doc(eventId).delete();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus event: $e');
    }
  }

  // ============ DAILY QUEST METHODS ============

  /// Update quest progress for a specific quest type
  Future<void> updateQuestProgress(
    String coupleId,
    String questType,
    int progress,
  ) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'dailyQuestProgress.$questType': progress,
      });
    } catch (e) {
      // Silent fail - quest is optional
    }
  }

  /// Reset daily quests (should be called when day changes)
  Future<void> resetDailyQuests(String coupleId) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'dailyQuestProgress': {'savings': 0, 'journey': 0, 'interaction': 0},
        'lastQuestResetDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Check and reset quests if new day
  Future<bool> checkAndResetQuestsIfNewDay(
    String coupleId,
    DateTime? lastResetDate,
  ) async {
    final now = DateTime.now();

    // If no last reset date or it's a new day, reset quests
    if (lastResetDate == null ||
        lastResetDate.year != now.year ||
        lastResetDate.month != now.month ||
        lastResetDate.day != now.day) {
      await resetDailyQuests(coupleId);
      return true; // Quests were reset
    }
    return false; // No reset needed
  }

  // ============ STREAK PROTECT METHODS ============

  /// Use a streak protect to prevent streak loss
  Future<bool> useStreakProtect(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final currentProtects = data['streakProtects'] ?? 0;

      if (currentProtects <= 0) {
        Get.snackbar('🛡️ Habis!', 'Tidak ada Streak Protect tersisa');
        return false;
      }

      await couplesCollection.doc(coupleId).update({
        'streakProtects': currentProtects - 1,
      });

      Get.snackbar(
        '🛡️ Streak Protected!',
        'Streak kamu diselamatkan! Sisa: ${currentProtects - 1}',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset monthly protects (should be called at start of each month)
  Future<void> resetMonthlyProtects(String coupleId) async {
    try {
      final now = DateTime.now();
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final lastResetMonth = data['lastProtectResetMonth'] ?? 0;

      // Reset if new month
      if (lastResetMonth != now.month) {
        await couplesCollection.doc(coupleId).update({
          'streakProtects': 2,
          'lastProtectResetMonth': now.month,
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Check if streak should be protected (auto-use protect if missed yesterday)
  Future<void> checkAndAutoProtectStreak(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final lastCheckIn = data['lastCheckIn'] != null
          ? (data['lastCheckIn'] is Timestamp
                ? (data['lastCheckIn'] as Timestamp).toDate()
                : DateTime.tryParse(data['lastCheckIn']))
          : null;
      final currentStreak = data['streak'] ?? 0;
      final currentProtects = data['streakProtects'] ?? 0;

      if (lastCheckIn == null || currentStreak == 0) return;

      final now = DateTime.now();
      final daysSinceLastCheckIn = now.difference(lastCheckIn).inDays;

      // If missed exactly 1 day and has protects available
      if (daysSinceLastCheckIn == 1 && currentProtects > 0) {
        // Auto-use protect (streak won't reset on next check-in)
        await couplesCollection.doc(coupleId).update({
          'streakProtects': currentProtects - 1,
          // Mark that protect was used today
          'lastCheckIn': FieldValue.serverTimestamp(),
        });
        Get.snackbar(
          '🛡️ Auto-Protected!',
          'Streak-mu diselamatkan secara otomatis! Sisa shield: ${currentProtects - 1}',
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  // ============ WEEKLY CHALLENGE METHODS ============

  /// Initialize or get current weekly challenge
  Future<Map<String, dynamic>?> initWeeklyChallenge(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final existingChallenge =
          data['weeklyChallenge'] as Map<String, dynamic>?;

      // Check if challenge exists and is still valid
      if (existingChallenge != null) {
        final endDate = DateTime.tryParse(existingChallenge['endDate'] ?? '');
        if (endDate != null && endDate.isAfter(DateTime.now())) {
          return existingChallenge; // Challenge still active
        }
      }

      // Create new weekly challenge
      final now = DateTime.now();
      final endOfWeek = now.add(
        Duration(days: 7 - now.weekday),
      ); // Until Sunday

      final challenges = [
        {
          'id': 'savings_streak',
          'title': 'Nabung 7 Hari Berturut-turut',
          'description': 'Tambah tabungan setiap hari selama seminggu',
          'targetProgress': 7,
          'rewardXP': 500,
          'rewardBadge': '💎 Super Saver',
        },
        {
          'id': 'check_in_master',
          'title': 'Check-in Master',
          'description': 'Check-in setiap hari selama seminggu',
          'targetProgress': 7,
          'rewardXP': 300,
          'rewardBadge': '🔥 Consistency King',
        },
        {
          'id': 'interaction_pro',
          'title': 'Lovey Dovey',
          'description': 'Interaksi dengan pasangan 20x minggu ini',
          'targetProgress': 20,
          'rewardXP': 400,
          'rewardBadge': '💕 Sweet Couple',
        },
      ];

      // Pick random challenge
      final randomChallenge = challenges[Random().nextInt(challenges.length)];

      final newChallenge = {
        ...randomChallenge,
        'currentProgress': 0,
        'startDate': now.toIso8601String(),
        'endDate': endOfWeek.toIso8601String(),
        'isClaimed': false,
      };

      await couplesCollection.doc(coupleId).update({
        'weeklyChallenge': newChallenge,
      });

      return newChallenge;
    } catch (e) {
      return null;
    }
  }

  /// Update weekly challenge progress
  Future<void> updateWeeklyChallengeProgress(
    String coupleId,
    int progress,
  ) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'weeklyChallenge.currentProgress': progress,
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Claim weekly challenge reward
  Future<bool> claimWeeklyChallengeReward(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final challenge = data['weeklyChallenge'] as Map<String, dynamic>?;

      if (challenge == null) return false;

      final currentProgress = challenge['currentProgress'] ?? 0;
      final targetProgress = challenge['targetProgress'] ?? 1;
      final isClaimed = challenge['isClaimed'] ?? false;
      final rewardXP = challenge['rewardXP'] ?? 0;

      if (currentProgress < targetProgress || isClaimed) {
        return false;
      }

      // Add XP and mark as claimed
      await couplesCollection.doc(coupleId).update({
        'weeklyChallenge.isClaimed': true,
        'totalXP': FieldValue.increment(rewardXP),
      });

      Get.snackbar(
        '🎉 Challenge Complete!',
        '+$rewardXP XP | ${challenge['rewardBadge']}',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // BADGE PROGRESS TRACKING
  // ============================================================

  /// Update specific badge progress
  Future<void> updateBadgeProgress(
    String coupleId,
    String badgeKey,
    int value,
  ) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'badgeProgress.$badgeKey': value,
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Increment badge progress by 1
  Future<void> incrementBadgeProgress(String coupleId, String badgeKey) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'badgeProgress.$badgeKey': FieldValue.increment(1),
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Get current badge progress
  Future<Map<String, int>> getBadgeProgress(String coupleId) async {
    try {
      final doc = await couplesCollection.doc(coupleId).get();
      if (!doc.exists) return {};
      final data = doc.data() as Map<String, dynamic>;
      return Map<String, int>.from(data['badgeProgress'] ?? {});
    } catch (e) {
      return {};
    }
  }

  /// Reset daily badge counters (profileViewsToday, appOpensThisHour)
  Future<void> resetDailyBadgeProgress(String coupleId) async {
    try {
      await couplesCollection.doc(coupleId).update({
        'badgeProgress.profileViewsToday': 0,
        'badgeProgress.appOpensThisHour': 0,
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Increment days without withdrawal (called when user doesn't withdraw)
  Future<void> incrementDaysWithoutWithdrawal(String coupleId) async {
    await incrementBadgeProgress(coupleId, 'daysWithoutWithdrawal');
  }

  /// Reset days without withdrawal (called when user withdraws)
  Future<void> resetDaysWithoutWithdrawal(String coupleId) async {
    await updateBadgeProgress(coupleId, 'daysWithoutWithdrawal', 0);
  }

  /// Increment profile views today (for Stalker badge)
  Future<void> incrementProfileViews(String coupleId) async {
    await incrementBadgeProgress(coupleId, 'profileViewsToday');
  }

  /// Increment goals completed (for To The Moon badge)
  Future<void> incrementGoalsCompleted(String coupleId) async {
    await incrementBadgeProgress(coupleId, 'goalsCompleted');
  }

  /// Increment memories saved (for Memory Hoarder badge)
  Future<void> incrementMemoriesSaved(String coupleId) async {
    await incrementBadgeProgress(coupleId, 'memoriesSaved');
  }

  /// Track app opens (for Bucin badge)
  Future<void> incrementAppOpens(String coupleId) async {
    await incrementBadgeProgress(coupleId, 'appOpensThisHour');
  }
}
