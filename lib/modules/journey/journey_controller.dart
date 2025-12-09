import 'package:chirax/modules/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/journey_event.dart';

class JourneyController extends GetxController {
  // === STATE ===
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rx<DateTime>(DateTime.now());
  final events = <DateTime, List<JourneyEvent>>{}.obs;

  // === FORM ===
  final titleController = TextEditingController();
  final selectedCategoryIndex = 0.obs;
  final isSurpriseEvent = false.obs;

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

  void addEvent({
    required String title,
    required DateTime date,
    required int categoryIndex,
    bool isSurprise = false,
    bool updateQuest = true,
  }) {
    final category = EventCategory.categories[categoryIndex];
    final normalizedDate = _normalizeDate(date);
    final newEvent = JourneyEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: normalizedDate,
      category: category.id,
      color: isSurprise ? JourneyEvent.surpriseColor : category.color,
      icon: isSurprise ? '🎁' : category.icon,
      isSurprise: isSurprise,
      createdBy: 'me',
    );

    if (events.containsKey(normalizedDate)) {
      events[normalizedDate]!.add(newEvent);
    } else {
      events[normalizedDate] = [newEvent];
    }

    events.refresh();

    // Hook to quest system - update journey quest progress
    if (updateQuest) {
      try {
        Get.find<HomeController>().updateQuestProgress('journey');
      } catch (e) {
        // HomeController not ready yet, skip
      }
    }
  }

  void deleteEvent(JourneyEvent event) {
    final normalizedDate = _normalizeDate(event.date);
    events[normalizedDate]?.removeWhere((e) => e.id == event.id);
    if (events[normalizedDate]?.isEmpty ?? false) {
      events.remove(normalizedDate);
    }
    events.refresh();
  }

  void resetForm() {
    titleController.clear();
    selectedCategoryIndex.value = 0;
    isSurpriseEvent.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    final now = DateTime.now();

    // Today - updateQuest: false to skip quest update during init
    addEvent(
      title: 'Dinner Date',
      date: now,
      categoryIndex: 0,
      updateQuest: false,
    );

    // 3 days
    addEvent(
      title: 'Monthly Anniversary',
      date: now.add(const Duration(days: 3)),
      categoryIndex: 1,
      updateQuest: false,
    );

    // 7 days
    addEvent(
      title: 'Trip to Bandung',
      date: now.add(const Duration(days: 7)),
      categoryIndex: 2,
      updateQuest: false,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}

/// Simple Bottom Sheet untuk Add Event (StatelessWidget biasa)
void showAddEventSheet(JourneyController controller) {
  controller.resetForm();
  final date = controller.selectedDay.value;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        bool isButtonPressed = false;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(0, -4),
                blurRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('📅', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Event', style: AppTextStyles.title),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title field with 3D border
                Text('Judul Event', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.titleController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Dinner Date...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category
                Text('Kategori', style: AppTextStyles.subtitle),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(EventCategory.categories.length, (
                      i,
                    ) {
                      final cat = EventCategory.categories[i];
                      final isSelected =
                          controller.selectedCategoryIndex.value == i;
                      return GestureDetector(
                        onTap: () => controller.selectedCategoryIndex.value = i,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cat.color
                                : cat.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cat.color, width: 2.5),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: cat.color.withValues(alpha: 0.4),
                                      offset: const Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : cat.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 28),

                // Add button - 3D Bouncy Style
                StatefulBuilder(
                  builder: (context, setButtonState) {
                    return GestureDetector(
                      onTapDown: (_) =>
                          setButtonState(() => isButtonPressed = true),
                      onTapUp: (_) {
                        setButtonState(() => isButtonPressed = false);
                        if (controller.titleController.text.isNotEmpty) {
                          controller.addEvent(
                            title: controller.titleController.text,
                            date: date,
                            categoryIndex:
                                controller.selectedCategoryIndex.value,
                          );
                        }
                        Get.back();
                      },
                      onTapCancel: () =>
                          setButtonState(() => isButtonPressed = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        transform: Matrix4.translationValues(
                          0,
                          isButtonPressed ? 4 : 0,
                          0,
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successShadow,
                              offset: Offset(0, isButtonPressed ? 2 : 5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TAMBAH EVENT',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
