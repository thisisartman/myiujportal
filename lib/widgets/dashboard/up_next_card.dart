import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

class UpNextCard extends ConsumerWidget {
  const UpNextCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    // Today is April 1; find next upcoming event on or after day 1
    final upcoming = events
        .where((e) => e.date >= 1)
        .toList()
      ..sort((a, b) {
        if (a.date != b.date) return a.date.compareTo(b.date);
        return a.time.compareTo(b.time);
      });

    if (upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

    final next = upcoming.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: next.type.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: next.type.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: next.type.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.access_time_rounded, color: next.type.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Up Next',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: next.type.color, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  next.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
                Text(
                  'Apr ${next.date} at ${next.time}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
