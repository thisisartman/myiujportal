import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_data.dart';
import '../../providers/meeting_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../common/dashboard_card.dart';
import '../common/toast_overlay.dart';

class GroupMeetingPollsCard extends ConsumerWidget {
  const GroupMeetingPollsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerPolls = ref
        .watch(meetingProvider)
        .values
        .where(
          (meeting) =>
              meeting.status == 'pending' &&
              meeting.creatorId != kMockStudentInfo.studentId,
        )
        .map(_pollFromMeeting)
        .toList();
    final polls = providerPolls.isEmpty ? kMockDashboardPolls : providerPolls;
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.groups_2_outlined,
        text: 'Group polls',
      ),
      actionLabel: '${polls.length} pending',
      onAction: polls.isEmpty ? null : () => _showPollList(context, polls),
      child: Column(
        children: polls
            .map((poll) => _PollTile(poll: poll))
            .toList(growable: false),
      ),
    );
  }

  MockMeetingPoll _pollFromMeeting(MeetingData meeting) {
    return MockMeetingPoll(
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
    );
  }

  Future<void> _showPollList(
    BuildContext context,
    List<MockMeetingPoll> polls,
  ) {
    return AppModal.show<void>(
      context,
      title: 'Pending group polls',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: polls
            .map((poll) => _PollTile(poll: poll))
            .toList(growable: false),
      ),
    );
  }
}

class _PollTile extends StatefulWidget {
  final MockMeetingPoll poll;

  const _PollTile({required this.poll});

  @override
  State<_PollTile> createState() => _PollTileState();
}

class _PollTileState extends State<_PollTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => _showPollModal(context, poll),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _hovering ? -1 : 0, 0),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.tealTint2 : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovering ? AppColors.primary : AppColors.ruleSoft,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${poll.from} invited you',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                poll.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _AvatarStack(labels: poll.attendees.take(4).toList()),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${poll.submitted}/${poll.total} submitted · ${poll.slotCount} slots',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPollModal(BuildContext context, MockMeetingPoll poll) {
    final outerContext = context;
    final selected = <String>{};
    final slots = ['09:00', '10:40', '13:15', '16:30'];
    return AppModal.show<void>(
      context,
      title: poll.title,
      child: StatefulBuilder(
        builder: (modalContext, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...slots.map(
              (slot) => CheckboxListTile(
                value: selected.contains(slot),
                title: Text(slot),
                activeColor: AppColors.primary,
                onChanged: (_) => setState(() {
                  selected.contains(slot)
                      ? selected.remove(slot)
                      : selected.add(slot);
                }),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: selected.isEmpty
                    ? null
                    : () {
                        Navigator.of(modalContext).pop();
                        showToast(
                          outerContext,
                          'Availability submitted.',
                          type: ToastType.success,
                        );
                      },
                child: const Text('Submit availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<String> labels;

  const _AvatarStack({required this.labels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22.0 + (labels.length - 1).clamp(0, 6) * 16.0,
      height: 22,
      child: Stack(
        children: labels.indexed.map((entry) {
          final (index, label) = entry;
          return Positioned(
            left: index * 16,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.surface,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: _colorFor(label),
                child: Text(
                  label.length <= 2
                      ? label.toUpperCase()
                      : label.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
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

  Color _colorFor(String label) {
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
