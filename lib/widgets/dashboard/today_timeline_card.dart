import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../models/calendar_event.dart';
import '../../providers/directory_provider.dart';
import '../../providers/meeting_provider.dart';
import '../../theme/app_colors.dart';
import '../calendar/event_detail_modal.dart';
import '../common/app_modal.dart';
import '../common/dashboard_card.dart';
import 'dashboard_event_utils.dart';

class TodayTimelineCard extends ConsumerWidget {
  final List<CalendarEvent> events;

  const TodayTimelineCard({super.key, required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...events]..sort((a, b) => a.time.compareTo(b.time));
    final nowIndex = _currentEventIndex(sorted);
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.timeline_outlined,
        text: "Today's timeline",
      ),
      actionLabel: 'View all',
      onAction: () => context.go('/calendar'),
      child: Column(
        children: [
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No scheduled items for today.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            )
          else
            ...sorted.indexed.map((entry) {
              final (index, event) = entry;
              return _TimelineRow(
                event: event,
                isNow: index == nowIndex,
                isPast: index < nowIndex,
              );
            }),
          const SizedBox(height: 14),
          const _DashedDivider(),
          const SizedBox(height: 14),
          const _CalendarUpdatesSection(),
        ],
      ),
    );
  }

  int _currentEventIndex(List<CalendarEvent> sorted) {
    if (sorted.isEmpty) return -1;
    final now = DateTime.now();
    final starts = sorted.map(dashboardEventDateTime).toList();
    for (var i = 0; i < starts.length; i++) {
      final start = starts[i];
      final next = i + 1 < starts.length ? starts[i + 1] : null;
      if (!start.isAfter(now) && (next == null || next.isAfter(now))) {
        return i;
      }
    }
    return starts.first.isAfter(now) ? -1 : sorted.length - 1;
  }
}

class _TimelineRow extends ConsumerWidget {
  final CalendarEvent event;
  final bool isPast;
  final bool isNow;

  const _TimelineRow({
    required this.event,
    required this.isPast,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = parseDashboardEventMeta(event.detail);
    return GestureDetector(
      onTap: () => AppModal.show(
        context,
        title: event.title,
        child: EventDetailModal(event: event),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              child: Text(
                event.time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPast ? AppColors.textMuted : AppColors.ink2,
                ),
              ),
            ),
            SizedBox(
              width: 18,
              child: _TimelineMarker(event.type, isNow, isPast),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isPast ? AppColors.textMuted : AppColors.ink2,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _TypeChip(type: event.type),
                      if (meta.course != null)
                        _TimelineChip(
                          label: meta.course!,
                          onTap: () => context.go(
                            '/wiki/course-${dashboardCourseId(meta.course!)}',
                          ),
                        ),
                      if (meta.room != null)
                        _TimelineChip(
                          label: meta.room!,
                          icon: Icons.location_on_outlined,
                          onTap: () => context.go('/facilities/room-booking'),
                        ),
                      if (meta.professor != null)
                        _TimelineChip(
                          label: meta.professor!,
                          icon: Icons.person_outline,
                          onTap: () {
                            ref.read(directorySearchProvider.notifier).state =
                                meta.professor!;
                            ref.read(directoryFilterProvider.notifier).state =
                                'Faculty';
                            context.go('/facilities/directory');
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  final CalendarEventType type;
  final bool isNow;
  final bool isPast;

  const _TimelineMarker(this.type, this.isNow, this.isPast);

  @override
  Widget build(BuildContext context) {
    final color = isPast ? AppColors.textMuted : _markerColor;
    final fill = type == CalendarEventType.assignment || isNow;
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 10,
            bottom: 0,
            child: Container(width: 2, color: AppColors.ruleSofter),
          ),
          Container(
            width: isNow ? 16 : 10,
            height: isNow ? 16 : 10,
            decoration: BoxDecoration(
              color: fill ? color : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: isNow
                  ? [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.9),
                        spreadRadius: 4,
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Color get _markerColor {
    return switch (type) {
      CalendarEventType.class_ => AppColors.primary,
      CalendarEventType.assignment => AppColors.danger,
      CalendarEventType.event => AppColors.warning,
    };
  }
}

class _TypeChip extends StatelessWidget {
  final CalendarEventType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (type) {
      CalendarEventType.class_ => (
        'Class',
        AppColors.tealInk,
        AppColors.tealTint2,
      ),
      CalendarEventType.assignment => (
        'Assignment',
        AppColors.danger,
        AppColors.dangerLight,
      ),
      CalendarEventType.event => (
        'Event',
        AppColors.warning,
        AppColors.warningLight,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _TimelineChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _TimelineChip({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.bgSunken,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.ruleSofter),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarUpdatesSection extends ConsumerWidget {
  const _CalendarUpdatesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerPolls = ref
        .watch(meetingProvider)
        .values
        .where((meeting) => meeting.status == 'pending')
        .map(
          (meeting) => MockMeetingPoll(
            code: meeting.code,
            from: meeting.creatorId,
            title: 'Group meeting poll ${meeting.code}',
            submitted: meeting.attendeeAvailability.length,
            total: 4,
            slotCount: meeting.attendeeAvailability.values.fold<int>(
              0,
              (count, slots) => count + slots.length,
            ),
            attendees: meeting.attendeeAvailability.keys.toList(),
          ),
        )
        .toList();
    final polls = providerPolls.isEmpty ? kMockDashboardPolls : providerPolls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Calendar updates',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${polls.length} pending',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...polls.take(2).map((poll) => _CalendarPollRow(poll: poll)),
      ],
    );
  }
}

class _CalendarPollRow extends StatelessWidget {
  final MockMeetingPoll poll;

  const _CalendarPollRow({required this.poll});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/meeting/${poll.code}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSunken,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ruleSofter),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        poll.from,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const _AwaitingChip(),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    poll.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _InlineAvatarStack(
                        labels: poll.attendees.take(4).toList(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${poll.submitted}/${poll.total} submitted',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineAvatarStack extends StatelessWidget {
  final List<String> labels;

  const _InlineAvatarStack({required this.labels});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 20.0 + (labels.length - 1).clamp(0, 6) * 14.0,
      height: 20,
      child: Stack(
        children: labels.indexed.map((entry) {
          final (index, label) = entry;
          return Positioned(
            left: index * 14,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.surface,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: _avatarColor(label),
                child: Text(
                  label.length <= 2
                      ? label.toUpperCase()
                      : label.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _avatarColor(String label) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.tealInk,
    ];
    return colors[label.hashCode.abs() % colors.length];
  }
}

class _AwaitingChip extends StatelessWidget {
  const _AwaitingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ruleSofter),
      ),
      child: const Text(
        'Awaits you',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            count,
            (index) => Expanded(
              child: Container(
                height: 1,
                margin: EdgeInsets.only(right: index == count - 1 ? 0 : 4),
                color: index.isEven ? AppColors.rule : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}
