import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';
import '../../theme/app_colors.dart';

class MonthGrid extends ConsumerWidget {
  const MonthGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayed = ref.watch(displayedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthEvents = ref.watch(monthEventsProvider);
    final today = DateTime.now();
    final isThisMonth =
        displayed.month == today.month && displayed.year == today.year;

    final daysInMonth = DateTime(displayed.year, displayed.month + 1, 0).day;
    final firstWeekday = DateTime(
      displayed.year,
      displayed.month,
      1,
    ).weekday; // 1=Mon
    final leadingBlanks = firstWeekday - 1; // 0 = starts on Monday

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final monthName = DateFormat('MMMM').format(displayed);
    final year = displayed.year;

    return Column(
      children: [
        // Month navigation with tappable month and year
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () {
                final cur = ref.read(displayedMonthProvider);
                final next = DateTime(cur.year, cur.month - 1);
                ref.read(displayedMonthProvider.notifier).state = next;
                ref.read(currentViewDateProvider.notifier).state = DateTime(
                  next.year,
                  next.month,
                  1,
                );
              },
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showMonthPicker(context, ref, displayed),
                child: Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showYearPicker(context, ref, displayed),
                child: Text(
                  '$year',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                final cur = ref.read(displayedMonthProvider);
                final next = DateTime(cur.year, cur.month + 1);
                ref.read(displayedMonthProvider.notifier).state = next;
                ref.read(currentViewDateProvider.notifier).state = DateTime(
                  next.year,
                  next.month,
                  1,
                );
              },
            ),
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                ref.read(displayedMonthProvider.notifier).state = DateTime(
                  now.year,
                  now.month,
                );
                ref.read(currentViewDateProvider.notifier).state = DateTime(
                  now.year,
                  now.month,
                  1,
                );
                ref.read(selectedDateProvider.notifier).state = now.day;
              },
              child: const Text(
                'Today',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Day headers
        Row(
          children: dayLabels
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final isSelected = day == selectedDate;
            final isToday = isThisMonth && day == today.day;
            final dayEvents = monthEvents[day] ?? <CalendarEvent>[];

            return _DayCell(
              day: day,
              isSelected: isSelected,
              isToday: isToday,
              events: dayEvents,
              onTap: () => ref.read(selectedDateProvider.notifier).state = day,
            );
          },
        ),
      ],
    );
  }
}

void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime current) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Month',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final isSelected = current.month == i + 1;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      final next = DateTime(current.year, i + 1);
                      ref.read(displayedMonthProvider.notifier).state = next;
                      ref.read(currentViewDateProvider.notifier).state =
                          DateTime(next.year, next.month, 1);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showYearPicker(BuildContext context, WidgetRef ref, DateTime current) {
  final currentYear = DateTime.now().year;
  final years = List.generate(3, (i) => currentYear - 1 + i);
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Year',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: years.map((y) {
                final isSelected = current.year == y;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      final next = DateTime(y, current.month);
                      ref.read(displayedMonthProvider.notifier).state = next;
                      ref.read(currentViewDateProvider.notifier).state =
                          DateTime(next.year, next.month, 1);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 72,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DayCell extends StatefulWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : (_hovering || widget.isToday ? AppColors.primaryLight : null),
            borderRadius: BorderRadius.circular(8),
            border: widget.isToday && !widget.isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              if (widget.events.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.events
                      .take(3)
                      .map(
                        (e) => Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 2, left: 1),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? Colors.white70
                                : e.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
