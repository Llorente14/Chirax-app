import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_card.dart';
import '../../data/models/journey_event.dart';
import 'journey_controller.dart';

class JourneyView extends GetView<JourneyController> {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('📅 Our Journey', style: AppTextStyles.headline),
            ),

            // Calendar
            Obx(() => _buildCalendar()),

            const SizedBox(height: 16),

            // Event List or Empty State
            Expanded(child: Obx(() => _buildEventListOrEmpty())),
          ],
        ),
      ),
      floatingActionButton: _buildChunkyFAB(),
    );
  }

  /// Chunky FAB dengan 3D shadow effect
  Widget _buildChunkyFAB() {
    return GestureDetector(
      onTap: () => controller.showAddEventSheet(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryShadow,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return ChunkyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      child: TableCalendar<JourneyEvent>(
        firstDay: controller.firstDay,
        lastDay: controller.lastDay,
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) =>
            isSameDay(controller.selectedDay.value, day),
        eventLoader: controller.getEventsForDay,
        onDaySelected: controller.onDaySelected,
        onPageChanged: (focusedDay) {
          controller.focusedDay.value = focusedDay;
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.title,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
          weekendStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 2),
          ),
          todayTextStyle: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          weekendTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
        ),
      ),
    );
  }

  /// Event List atau Empty State
  Widget _buildEventListOrEmpty() {
    final events = controller.getEventsForDay(controller.selectedDay.value);

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAnimatedEventList(events);
  }

  /// Empty State dengan animasi
  Widget _buildEmptyState() {
    return AnimationLimiter(
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 400),
          child: FadeInAnimation(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 80,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No plans for this day yet',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create a memory',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Animated Event List dengan staggered animation
  Widget _buildAnimatedEventList(List<JourneyEvent> events) {
    // Key unik berdasarkan tanggal agar animasi di-trigger ulang
    final selectedDate = controller.selectedDay.value;
    final listKey = ValueKey(
      '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
    );

    return AnimationLimiter(
      key: listKey,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Dismissible(
                  key: Key(event.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => controller.deleteEvent(event),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  child: _buildEventCard(event),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(JourneyEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: event.color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: event.color.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(event.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),

          // Title & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                Text(
                  event.category.capitalizeFirst ?? event.category,
                  style: AppTextStyles.bodySmall.copyWith(color: event.color),
                ),
              ],
            ),
          ),

          // Swipe hint
          Icon(
            Icons.chevron_left_rounded,
            color: Colors.grey.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
