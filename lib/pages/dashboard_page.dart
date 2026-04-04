import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_provider.dart';
import '../widgets/dashboard/calendar_widget.dart';
import '../widgets/dashboard/up_next_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _header(),
        const SizedBox(height: 24),
        // Quick actions
        _quickActions(context),
        const SizedBox(height: 24),
        // Main grid
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: const DashboardCalendarWidget()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _rightColumn(context, ref)),
                ],
              )
            : Column(
                children: [
                  const DashboardCalendarWidget(),
                  const SizedBox(height: 16),
                  _rightColumn(context, ref),
                ],
              ),
      ],
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Good morning, Student! 👋',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 4),
        Text(
          'Wednesday, April 1, 2026',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      _Action(icon: Icons.calendar_today_outlined, label: 'Calendar', color: const Color(0xFF4F46E5), path: '/calendar'),
      _Action(icon: Icons.business_outlined, label: 'Facilities', color: const Color(0xFF059669), path: '/facilities'),
      _Action(icon: Icons.local_library_outlined, label: 'Wiki', color: const Color(0xFF0891B2), path: '/wiki'),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => context.go(a.path),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Icon(a.icon, color: a.color, size: 22),
                  const SizedBox(height: 6),
                  Text(a.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _rightColumn(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    // Next events after today
    final upcoming = events.where((e) => e.date >= 2).toList()
      ..sort((a, b) {
        if (a.date != b.date) return a.date.compareTo(b.date);
        return a.time.compareTo(b.time);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UpNextCard(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coming Up', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              ...upcoming.take(4).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: e.type.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${e.date}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: e.type.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                          Text('Apr ${e.date} at ${e.time}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String path;
  const _Action({required this.icon, required this.label, required this.color, required this.path});
}
