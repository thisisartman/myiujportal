import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';

/// Mock "today" is April 6, 2026 — kept in sync with mock_data seed.
const int kMockTodayDay = 6;

class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    final upcoming = events.where((e) => e.date >= kMockTodayDay).toList()
      ..sort((a, b) {
        if (a.date != b.date) return a.date.compareTo(b.date);
        return a.time.compareTo(b.time);
      });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text('Upcoming Events', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/calendar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('View all', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No upcoming events.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            )
          else
            ...upcoming.take(5).map((e) => _EventRow(event: e)),
          const SizedBox(height: 4),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(event.type.label, event.type.color, event.type.bgColor, () => context.go('/calendar')),
              const SizedBox(width: 6),
              Text('Apr ${event.date}  ${event.time}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 3),
          Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _detailChips(context, event.detail),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailChips(BuildContext context, String detail) {
    final parts = detail.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return parts.map((part) {
      final isCourseCode = RegExp(r'^[A-Z]{2,4}\d{4}$').hasMatch(part.replaceAll('-', '').replaceAll(' ', ''));
      return _chip(part, const Color(0xFF6B7280), const Color(0xFFF3F4F6), () {
        if (isCourseCode) {
          context.go('/wiki');
        } else {
          context.go('/calendar');
        }
      });
    }).toList();
  }

  Widget _chip(String label, Color fg, Color bg, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
        ),
      ),
    );
  }
}
