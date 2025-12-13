import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/journey_event.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../home/home_controller.dart';

class JourneyController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();

  // === STATE ===
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rx<DateTime>(DateTime.now());
  final events = <DateTime, List<JourneyEvent>>{}.obs;
  final isLoading = true.obs;

  // === FORM ===
  final titleController = TextEditingController();
  final selectedCategoryIndex = 0.obs;
  final isSurpriseEvent = false.obs;

  // === STREAM ===
  StreamSubscription? _eventsSubscription;

  // === GETTERS ===

  /// Get coupleId from AuthService
  String? get coupleId => _authService.userModel.value?.coupleId;

  /// Current user UID
  String? get currentUserId => _authService.currentUser?.value?.uid;

  // === BOUNDS ===
  DateTime get firstDay => DateTime.now().subtract(const Duration(days: 365));
  DateTime get lastDay => DateTime.now().add(const Duration(days: 365 * 2));

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<JourneyEvent> getEventsForDay(DateTime day) {
    return events[_normalizeDate(day)] ?? [];
  }

  JourneyEvent? get nextBigEvent {
    final now = _normalizeDate(DateTime.now());
    JourneyEvent? nextEvent;
    int? minDays;

    for (final entry in events.entries) {
      for (final event in entry.value) {
        if (event.category == 'anniversary' || event.category == 'trip') {
          final daysUntil = _normalizeDate(event.date).difference(now).inDays;
          if (daysUntil > 0 && (minDays == null || daysUntil < minDays)) {
            minDays = daysUntil;
            nextEvent = event;
          }
        }
      }
    }
    return nextEvent;
  }

  int getDaysUntil(JourneyEvent event) {
    return _normalizeDate(
      event.date,
    ).difference(_normalizeDate(DateTime.now())).inDays;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = _normalizeDate(selected);
    focusedDay.value = focused;
  }

  /// Add event to Firestore
  Future<void> addEvent({
    required String title,
    required DateTime date,
    required int categoryIndex,
    bool isSurprise = false,
    bool updateQuest = true,
  }) async {
    if (coupleId == null) return;

    final category = EventCategory.categories[categoryIndex];
    final normalizedDate = _normalizeDate(date);

    final newEvent = JourneyEvent(
      id: '', // Will be assigned by Firestore
      title: title,
      date: normalizedDate,
      category: category.id,
      color: isSurprise ? JourneyEvent.surpriseColor : category.color,
      icon: isSurprise ? '🎁' : category.icon,
      isSurprise: isSurprise,
      createdBy: currentUserId,
    );

    final result = await _dbService.addJourneyEvent(coupleId!, newEvent);
    if (result != null) {
      // Track badge progress: Memories Saved for "Memory Hoarder" badge
      await _dbService.incrementMemoriesSaved(coupleId!);

      // Hook to quest system - update journey quest progress
      if (updateQuest) {
        try {
          Get.find<HomeController>().updateQuestProgress('journey');
        } catch (e) {
          // HomeController not ready yet, skip
        }
      }

      Get.snackbar(
        '📅 Event Ditambahkan',
        '"$title" berhasil disimpan!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Delete event from Firestore
  Future<void> deleteEvent(JourneyEvent event) async {
    if (coupleId == null) return;
    await _dbService.deleteJourneyEvent(coupleId!, event.id);
  }

  void resetForm() {
    titleController.clear();
    selectedCategoryIndex.value = 0;
    isSurpriseEvent.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _initStream();
  }

  /// Initialize real-time stream from Firestore
  void _initStream() {
    // Wait for auth to be ready
    ever(_authService.userModel, (user) {
      if (user?.coupleId != null) {
        _startListeningEvents(user!.coupleId!);
      }
    });

    // Also try immediately if already authenticated
    if (coupleId != null) {
      _startListeningEvents(coupleId!);
    }
  }

  void _startListeningEvents(String coupleId) {
    _eventsSubscription?.cancel();
    isLoading.value = true;

    _eventsSubscription = _dbService
        .streamEvents(coupleId)
        .listen(
          (eventsList) {
            // Convert List<JourneyEvent> to Map<DateTime, List<JourneyEvent>>
            final Map<DateTime, List<JourneyEvent>> eventsMap = {};

            for (final event in eventsList) {
              final normalizedDate = _normalizeDate(event.date);
              if (eventsMap.containsKey(normalizedDate)) {
                eventsMap[normalizedDate]!.add(event);
              } else {
                eventsMap[normalizedDate] = [event];
              }
            }

            events.value = eventsMap;
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Gagal memuat events: $e');
          },
        );
  }

  @override
  void onClose() {
    titleController.dispose();
    _eventsSubscription?.cancel();
    super.onClose();
  }

  /// Show add event bottom sheet (UI unchanged)
  void showAddEventSheet() {
    titleController.clear();
    selectedCategoryIndex.value = 0;
    isSurpriseEvent.value = false;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Text(
              'Tambah Event 📅',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),

            const SizedBox(height: 20),

            // Event Title Input - Juicy 3D Style
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neutralShadow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutralShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Nama Event',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 20),

            // Category Selection - Wrap Style
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(EventCategory.categories.length, (i) {
                  final cat = EventCategory.categories[i];
                  final isSelected = selectedCategoryIndex.value == i;
                  return GestureDetector(
                    onTap: () => selectedCategoryIndex.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isSelected
                                  ? cat.color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Surprise Toggle
            Obx(
              () => GestureDetector(
                onTap: () => isSurpriseEvent.toggle(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSurpriseEvent.value
                        ? JourneyEvent.surpriseColor.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSurpriseEvent.value
                          ? JourneyEvent.surpriseColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSurpriseEvent.value ? '🎁' : '🤫',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jadikan Surprise',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSurpriseEvent.value
                              ? JourneyEvent.surpriseColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Add Button (Bouncy 3D)
            GestureDetector(
              onTap: () {
                if (titleController.text.isEmpty) {
                  Get.snackbar(
                    '⚠️ Oops!',
                    'Nama event tidak boleh kosong',
                    snackPosition: SnackPosition.TOP,
                  );
                  return;
                }
                addEvent(
                  title: titleController.text,
                  date: selectedDay.value,
                  categoryIndex: selectedCategoryIndex.value,
                  isSurprise: isSurpriseEvent.value,
                );
                Get.back();
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryShadow,
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah Event',
                        style: AppTextStyles.button.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
