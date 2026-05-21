import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../models/calendar_event.dart';
import '../../providers/meeting_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import 'event_detail_modal.dart';
import 'meeting_creator_modal.dart';

class EventCard extends ConsumerWidget {
  final CalendarEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = event;

    // Meeting event: different tap behaviour and title display
    if (e.meetingCode != null) {
      return _buildMeetingCard(context, ref, e);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => AppModal.show(
          context,
          title: e.title,
          child: EventDetailModal(event: e),
        ),
        child: _cardBody(e, subtitle: null),
      ),
    );
  }

  Widget _buildMeetingCard(
    BuildContext context,
    WidgetRef ref,
    CalendarEvent e,
  ) {
    final meeting = ref.watch(meetingProvider)[e.meetingCode!];
    final isCreator =
        meeting != null &&
        meeting.creatorId == kMockStudentInfo.studentId;

    String subtitle = 'Group meeting';
    if (meeting != null && isCreator) {
      final responded = meeting.attendeeAvailability.length - 1;
      subtitle = 'Pending — $responded/${meeting.totalInvitees} responded';
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (isCreator) {
            AppModal.show(
              context,
              title: 'Group Meeting',
              child: MeetingCreatorModal(code: e.meetingCode!),
            );
          } else {
            context.go('/meeting/${e.meetingCode}');
          }
        },
        child: _cardBody(e, subtitle: subtitle),
      ),
    );
  }

  Widget _cardBody(CalendarEvent e, {required String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: e.type.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: e.type.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: e.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeBadge(type: e.type),
                    const SizedBox(width: 6),
                    Text(
                      e.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  e.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else if (e.detail.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _detailChips(e),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailChips(CalendarEvent e) {
    final parts = e.detail
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.map((part) => _StaticChip(label: part)).toList();
  }
}

class _TypeBadge extends StatelessWidget {
  final CalendarEventType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: type.color,
        ),
      ),
    );
  }
}

class _StaticChip extends StatelessWidget {
  final String label;
  const _StaticChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
