import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

class DashboardCalendarWidget extends ConsumerWidget {
  const DashboardCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime(2026, 4, 1); // Mock today
    final events = ref.watch(calendarEventsProvider);
    final todayEvents = events.where((e) => e.date == today.day).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return GestureDetector(
      onTap: () => context.go('/calendar'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header — date number on top, day of week below, no location
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('d').format(today),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                          height: 1,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE').format(today),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(today),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6366F1), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Text('View calendar', style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5))),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 12, color: Color(0xFF4F46E5)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Events for today
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Schedule",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 8),
                  if (todayEvents.isEmpty)
                    const Text('No events today', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))
                  else
                    ...todayEvents.map((e) => _EventRow(event: e)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final CalendarEvent event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: event.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              Text(event.time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}
