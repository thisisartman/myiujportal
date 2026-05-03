import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';

class BookingCalendar extends StatelessWidget {
  final String facilityId;
  final void Function(int day) onDaySelected;

  const BookingCalendar({
    super.key,
    required this.facilityId,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekdayOffset = DateTime(now.year, now.month, 1).weekday - 1;
    final availableDays = kAvailableDaysForMonth(now.year, now.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            DateFormat('MMMM yyyy').format(now),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        _buildGrid(now.day, daysInMonth, firstWeekdayOffset, availableDays),
      ],
    );
  }

  Widget _buildGrid(
    int today,
    int daysInMonth,
    int offset,
    Set<int> availableDays,
  ) {
    final List<Widget> cells = [];
    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final isPast = day <= today;
      final tappable = !isPast && availableDays.contains(day);
      cells.add(
        _DayCell(
          day: day,
          tappable: tappable,
          isPast: isPast,
          onTap: tappable ? () => onDaySelected(day) : null,
        ),
      );
    }

    final List<Widget> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      final end = (i + 7 < cells.length) ? i + 7 : cells.length;
      final rowCells = cells.sublist(i, end);
      while (rowCells.length < 7) {
        rowCells.add(const SizedBox());
      }
      rows.add(Row(children: rowCells.map((c) => Expanded(child: c)).toList()));
      rows.add(const SizedBox(height: 4));
    }
    return Column(children: rows);
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool tappable;
  final bool isPast;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.tappable,
    required this.isPast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor = AppColors.textPrimary;

    if (isPast) {
      textColor = AppColors.textMuted;
    } else if (tappable) {
      bg = AppColors.primaryLight;
      textColor = AppColors.primary;
    } else {
      textColor = AppColors.textMuted;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
