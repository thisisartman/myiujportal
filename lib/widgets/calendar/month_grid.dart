import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: dayLabels
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.08,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
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
                onTap: () =>
                    ref.read(selectedDateProvider.notifier).state = day,
              );
            },
          ),
        ],
      ),
    );
  }
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
