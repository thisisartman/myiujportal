import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_colors.dart';

class UpcomingEventsWidget extends ConsumerStatefulWidget {
  const UpcomingEventsWidget({super.key});

  @override
  ConsumerState<UpcomingEventsWidget> createState() =>
      _UpcomingEventsWidgetState();
}

class _UpcomingEventsWidgetState extends ConsumerState<UpcomingEventsWidget> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(calendarEventsProvider);
    final today = DateTime.now().day;
    var upcoming = events.where((e) => e.date >= today).toList()
      ..sort((a, b) {
        if (a.date != b.date) return a.date.compareTo(b.date);
        return a.time.compareTo(b.time);
      });
    if (upcoming.isEmpty) {
      upcoming = [...events]
        ..sort((a, b) {
          if (a.date != b.date) return a.date.compareTo(b.date);
          return a.time.compareTo(b.time);
        });
    }
    final isWide = MediaQuery.of(context).size.width >= 900;
    final displayCount = (isWide || _showAll) ? 5 : 3;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/calendar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
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
              child: Text(
                'No upcoming events.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...upcoming
                        .take(displayCount)
                        .map((e) => _EventRow(event: e)),
                    if (!isWide && upcoming.length > 3 && !_showAll)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => _showAll = true),
                            child: Text(
                              'Read more (${upcoming.length - 3} more)',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _EventRow extends ConsumerWidget {
  final CalendarEvent event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(
                event.type.label,
                event.type.color,
                event.type.bgColor,
                () => context.go('/calendar'),
              ),
              const SizedBox(width: 6),
              Text(
                'Apr ${event.date}  ${event.time}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _detailChips(context, ref, event.detail),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailChips(
    BuildContext context,
    WidgetRef ref,
    String detail,
  ) {
    final parts = detail
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.map((part) {
      final normalized = part.replaceAll('-', '').replaceAll(' ', '');
      final isCourseCode = RegExp(r'^[A-Z]{2,5}\d{4,5}$').hasMatch(normalized);
      final isProfessor =
          RegExp(r'^[A-Z][A-Za-z .-]+$').hasMatch(part) &&
          !part.contains('Hall') &&
          !part.contains('Cafeteria');
      final isFacility = RegExp(
        r'(G\.|P\.|Hall|Cafeteria|Library|Gym|Room)',
      ).hasMatch(part);
      return _chip(part, AppColors.textSecondary, AppColors.background, () {
        if (isCourseCode) {
          context.go('/wiki/course-${normalized.toLowerCase()}');
        } else if (isProfessor) {
          context.go('/facilities/directory');
        } else if (isFacility) {
          context.go('/facilities/room-booking');
        } else {
          ref.read(calendarFilterProvider.notifier).state = event.type.name;
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
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
