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
    final isMockMonth = displayed.month == 4 && displayed.year == 2026;

    final daysInMonth = DateTime(displayed.year, displayed.month + 1, 0).day;
    int firstWeekday = DateTime(displayed.year, displayed.month, 1).weekday; // 1=Mon
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
                ref.read(displayedMonthProvider.notifier).state =
                    DateTime(cur.year, cur.month - 1);
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
                ref.read(displayedMonthProvider.notifier).state =
                    DateTime(cur.year, cur.month + 1);
              },
            ),
            TextButton(
              onPressed: () {
                ref.read(displayedMonthProvider.notifier).state = DateTime(2026, 4);
                ref.read(currentViewDateProvider.notifier).state = DateTime(2026, 4, 1);
                ref.read(selectedDateProvider.notifier).state = 1;
              },
              child: const Text('Today', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Day headers
        Row(
          children: dayLabels.map((d) => Expanded(
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
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.primaryLight : null),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
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
                        color: isSelected ? Colors.white : AppColors.textPrimary,
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

void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime current) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
                      ref.read(displayedMonthProvider.notifier).state =
                          DateTime(current.year, i + 1);
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
                          color: isSelected ? Colors.white : AppColors.textPrimary,
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
  final years = List.generate(10, (i) => current.year - 3 + i);
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
                      ref.read(displayedMonthProvider.notifier).state =
                          DateTime(y, current.month);
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
                          color: isSelected ? Colors.white : AppColors.textPrimary,
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
