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
import '../widgets/common/page_chrome.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final displayed = ref.watch(displayedMonthProvider);
    final isWide = MediaQuery.of(context).size.width >= 980;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Calendar',
          meta: [
            const MetaText('Spring 2026 · Week 6', emphasis: true),
            const MetaDot(),
            MetaText('${filteredEvents.length} items on selected day'),
          ],
          actions: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => GroupMeetingModal.show(context),
                icon: const Icon(Icons.groups_2_outlined, size: 16),
                label: const Text('Schedule group meeting'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEventModal(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add event'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: PageCard(
                      padding: EdgeInsets.zero,
                      header: PageCardHeader(
                        icon: Icons.calendar_month_outlined,
                        title: DateFormat('MMMM yyyy').format(displayed),
                        action: _CalendarToolbar(ref: ref),
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
                  PageCard(
                    padding: EdgeInsets.zero,
                    header: PageCardHeader(
                      icon: Icons.calendar_month_outlined,
                      title: DateFormat('MMMM yyyy').format(displayed),
                      action: _CalendarToolbar(ref: ref),
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
    return SoftChip(
      label: label,
      selected: filter == value,
      onTap: () => ref.read(calendarFilterProvider.notifier).state = value,
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
    return PageCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      header: PageCardHeader(
        icon: Icons.event_note_outlined,
        title: 'Selected day',
        action: ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          onPressed: () => _showAddEventModal(context, ref),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthName $selectedDate',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: SingleChildScrollView(
                child: Column(
                  children: events.map((e) => EventCard(event: e)).toList(),
                ),
              ),
            ),
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
                          year: displayed.year,
                          month: displayed.month,
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

class _CalendarToolbar extends StatelessWidget {
  final WidgetRef ref;

  const _CalendarToolbar({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () {
            final displayed = ref.read(displayedMonthProvider);
            ref.read(displayedMonthProvider.notifier).state = DateTime(
              displayed.year,
              displayed.month - 1,
            );
          },
          icon: const Icon(Icons.chevron_left, size: 18),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: () {
            final displayed = ref.read(displayedMonthProvider);
            ref.read(displayedMonthProvider.notifier).state = DateTime(
              displayed.year,
              displayed.month + 1,
            );
          },
          icon: const Icon(Icons.chevron_right, size: 18),
        ),
        OutlinedButton(
          onPressed: () {
            final now = DateTime.now();
            ref.read(displayedMonthProvider.notifier).state = now;
            ref.read(selectedDateProvider.notifier).state = now.day;
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          child: const Text('Today'),
        ),
      ],
    );
  }
}
