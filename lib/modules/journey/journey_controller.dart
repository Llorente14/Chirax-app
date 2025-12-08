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

    // Today
    addEvent(title: 'Dinner Date', date: now, categoryIndex: 0);

    // 3 days
    addEvent(
      title: 'Monthly Anniversary',
      date: now.add(const Duration(days: 3)),
      categoryIndex: 1,
    );

    // 7 days
    addEvent(
      title: 'Trip to Bandung',
      date: now.add(const Duration(days: 7)),
      categoryIndex: 2,
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
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Text('✨ Add Event', style: AppTextStyles.title),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title field
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'Event title...',
                filled: true,
                fillColor: AppColors.offWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            Text('Category', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(EventCategory.categories.length, (i) {
                  final cat = EventCategory.categories[i];
                  final isSelected =
                      controller.selectedCategoryIndex.value == i;
                  return GestureDetector(
                    onTap: () => controller.selectedCategoryIndex.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color
                            : cat.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat.color, width: 2),
                      ),
                      child: Text(
                        '${cat.icon} ${cat.label}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : cat.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.titleController.text.isNotEmpty) {
                    controller.addEvent(
                      title: controller.titleController.text,
                      date: date,
                      categoryIndex: controller.selectedCategoryIndex.value,
                    );
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'ADD EVENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
