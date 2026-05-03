import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_event.dart';
import '../theme/app_colors.dart';
import '../widgets/calendar/month_grid.dart';
import '../widgets/calendar/event_card.dart';
import '../widgets/calendar/group_meeting_modal.dart';
import '../widgets/common/app_modal.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final displayed = ref.watch(displayedMonthProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(displayed),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Content layout
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const MonthGrid(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _eventPanel(
                      context,
                      ref,
                      filteredEvents,
                      selectedDate,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const MonthGrid(),
                  ),
                  const SizedBox(height: 16),
                  _eventPanel(context, ref, filteredEvents, selectedDate),
                ],
              ),
      ],
    );
  }

  Widget _filterChip(String label, String value, String filter, WidgetRef ref) {
    final active = filter == value;
    return GestureDetector(
      onTap: () => ref.read(calendarFilterProvider.notifier).state = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _eventPanel(
    BuildContext context,
    WidgetRef ref,
    List<CalendarEvent> events,
    int selectedDate,
  ) {
    final displayed = ref.watch(displayedMonthProvider);
    final filter = ref.watch(calendarFilterProvider);
    final monthName = DateFormat('MMMM').format(displayed);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName $selectedDate',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: () => _showAddEventModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', 'all', filter, ref),
                const SizedBox(width: 8),
                _filterChip(
                  'Classes',
                  CalendarEventType.class_.name,
                  filter,
                  ref,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Assignments',
                  CalendarEventType.assignment.name,
                  filter,
                  ref,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Events',
                  CalendarEventType.event.name,
                  filter,
                  ref,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No events for this day',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...events.map((e) => EventCard(event: e)),
        ],
      ),
    );
  }

  void _showAddEventModal(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final timeController = TextEditingController(text: '09:00');
    CalendarEventType selectedType = CalendarEventType.class_;
    String selectedCourse = kEnrolledCourses.first;
    final selectedDate = ref.read(selectedDateProvider);
    final displayed = ref.read(displayedMonthProvider);

    AppModal.show(
      context,
      title: 'Add New Event',
      child: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CalendarEventType>(
              initialValue: selectedType,
              items: CalendarEventType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => selectedType = v!),
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailController,
              decoration: const InputDecoration(
                labelText: 'Detail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCourse,
              items: kEnrolledCourses
                  .map(
                    (course) =>
                        DropdownMenuItem(value: course, child: Text(course)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedCourse = value!),
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: false,
              initialValue: DateFormat(
                'MMMM d, yyyy',
              ).format(DateTime(displayed.year, displayed.month, selectedDate)),
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'or',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: () {
                Navigator.of(ctx).pop();
                GroupMeetingModal.show(context);
              },
              child: const Text('Schedule group meeting'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final notifier = ref.read(
                        calendarEventsProvider.notifier,
                      );
                      notifier.addEvent(
                        CalendarEvent(
                          id: notifier.nextId,
                          type: selectedType,
                          date: selectedDate,
                          time: timeController.text,
                          title: titleController.text,
                          detail: selectedCourse == kEnrolledCourses.first
                              ? detailController.text
                              : '${detailController.text} | $selectedCourse',
                        ),
                      );
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Add Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
