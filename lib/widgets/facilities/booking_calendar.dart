import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

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
    // Mock: April 2026. Days 1-6 are past (mock today = Apr 6).
    const int mockToday = 6;
    const int daysInMonth = 30;
    // April 1, 2026 is a Wednesday → offset 2 from Monday column
    const int firstWeekdayOffset = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'April 2026',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) =>
            Expanded(
              child: Center(
                child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 8),
        _buildGrid(mockToday, daysInMonth, firstWeekdayOffset),
      ],
    );
  }

  Widget _buildGrid(int mockToday, int daysInMonth, int offset) {
    final List<Widget> cells = [];
    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final isPast = day <= mockToday;
      final tappable = !isPast && kAvailableDays.contains(day);
      cells.add(_DayCell(
        day: day,
        tappable: tappable,
        isPast: isPast,
        onTap: tappable ? () => onDaySelected(day) : null,
      ));
    }

    final List<Widget> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      final end = (i + 7 < cells.length) ? i + 7 : cells.length;
      final rowCells = cells.sublist(i, end);
      while (rowCells.length < 7) { rowCells.add(const SizedBox()); }
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

  const _DayCell({required this.day, required this.tappable, required this.isPast, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor = const Color(0xFF111827);

    if (isPast) {
      textColor = const Color(0xFFD1D5DB);
    } else if (tappable) {
      bg = const Color(0xFFEEF2FF);
      textColor = const Color(0xFF4F46E5);
    } else {
      textColor = const Color(0xFFD1D5DB);
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ),
    );
  }
}
