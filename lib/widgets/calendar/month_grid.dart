import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

class MonthGrid extends ConsumerWidget {
  const MonthGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewDate = ref.watch(currentViewDateProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthEvents = ref.watch(monthEventsProvider);
    final isMockMonth = viewDate.month == 4 && viewDate.year == 2026;

    final daysInMonth = DateTime(viewDate.year, viewDate.month + 1, 0).day;
    int firstWeekday = DateTime(viewDate.year, viewDate.month, 1).weekday; // 1=Mon
    final leadingBlanks = firstWeekday - 1; // 0 = starts on Monday

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Month navigation
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(currentViewDateProvider.notifier).update(
                    (d) => DateTime(d.year, d.month - 1, 1),
                  ),
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(viewDate),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(currentViewDateProvider.notifier).update(
                    (d) => DateTime(d.year, d.month + 1, 1),
                  ),
            ),
            TextButton(
              onPressed: () {
                ref.read(currentViewDateProvider.notifier).state = DateTime(2026, 4, 1);
                ref.read(selectedDateProvider.notifier).state = 1;
              },
              child: const Text('Today', style: TextStyle(color: Color(0xFF4F46E5))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Day headers
        Row(
          children: dayLabels.map((d) => Expanded(
            child: Center(
              child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
            ),
          )).toList(),
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
            final isSelected = day == selectedDate && isMockMonth;
            final isToday = day == 1 && isMockMonth; // April 1 2026 = today
            final dayEvents = isMockMonth ? (monthEvents[day] ?? []) : <CalendarEvent>[];

            return GestureDetector(
              onTap: () => ref.read(selectedDateProvider.notifier).state = day,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : (isToday ? const Color(0xFFEEF2FF) : null),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    if (dayEvents.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dayEvents.take(3).map((e) => Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 2, left: 1),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white70 : e.type.color,
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
