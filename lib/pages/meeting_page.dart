import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../providers/meeting_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/calendar/meeting_creator_modal.dart';
import '../widgets/calendar/month_grid.dart';
import '../widgets/common/app_modal.dart';
import '../widgets/common/page_chrome.dart';
import '../widgets/common/toast_overlay.dart';

class MeetingPage extends ConsumerStatefulWidget {
  final String code;
  const MeetingPage({super.key, required this.code});

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  @override
  void initState() {
    super.initState();
    // Receiver: auto-open the invite modal once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final meeting = ref.read(meetingProvider)[widget.code];
      if (meeting == null) return;
      final isCreator = meeting.creatorId == kMockStudentInfo.studentId;
      if (!isCreator) {
        AppModal.show(
          context,
          title: 'Meeting Invite',
          child: _ReceiverPanel(code: widget.code),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meeting = ref.watch(meetingProvider)[widget.code];

    if (meeting == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This link has expired or is invalid.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      );
    }

    final isCreator = meeting.creatorId == kMockStudentInfo.studentId;

    return isCreator
        ? _creatorView(context, meeting)
        : _receiverBackground();
  }

  /// Creator sees meeting management; receiver sees the calendar grid
  /// (the receiver's invite modal is auto-opened in initState)
  String _durationStr(int minutes) =>
      minutes < 60 ? '$minutes min' : '${minutes ~/ 60} hr';

  Widget _receiverBackground() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Group Meeting',
          meta: const [MetaText('Select your available slots')],
        ),
        const SizedBox(height: 16),
        PageCard(
          padding: EdgeInsets.zero,
          header: const PageCardHeader(
            icon: Icons.calendar_month_outlined,
            title: 'Calendar',
          ),
          child: const MonthGrid(),
        ),
      ],
    );
  }

  Widget _creatorView(BuildContext context, MeetingData meeting) {
    final responded = meeting.attendeeAvailability.length - 1;
    final total = meeting.totalInvitees;
    final url = '/meeting/${widget.code}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Group Meeting',
          meta: [
            MetaText(
              DateFormat('MMMM d, yyyy').format(meeting.date),
              emphasis: true,
            ),
            const MetaDot(),
            MetaText(_durationStr(meeting.durationMinutes)),
          ],
        ),
        const SizedBox(height: 16),
        PageCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share this link with attendees',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: url)),
                      icon: const Icon(
                        Icons.copy_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Copy link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: responded >= total
                          ? AppColors.successLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$responded / $total responded',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: responded >= total
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('View responses'),
                    onPressed: () => AppModal.show(
                      context,
                      title: 'Confirm Meeting',
                      child: MeetingCreatorModal(code: widget.code),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Receiver panel shown inside the auto-opened AppModal
class _ReceiverPanel extends ConsumerStatefulWidget {
  final String code;
  const _ReceiverPanel({required this.code});

  @override
  ConsumerState<_ReceiverPanel> createState() => _ReceiverPanelState();
}

class _ReceiverPanelState extends ConsumerState<_ReceiverPanel> {
  final Set<String> _selected = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final meeting = ref.watch(meetingProvider)[widget.code];
    if (meeting == null) return const SizedBox.shrink();

    final slots = _suggestedSlots(meeting);
    final dateLabel = DateFormat('EEEE, MMMM d').format(meeting.date);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${meeting.durationMinutes} min · ${meeting.repetition == 'None' ? 'One-time' : meeting.repetition}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Select your available time slots:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final picked = _selected.contains(slot);
            return FilterChip(
              label: Text(slot),
              selected: picked,
              onSelected: _submitted
                  ? null
                  : (v) => setState(
                        () => v ? _selected.add(slot) : _selected.remove(slot),
                      ),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: picked ? AppColors.primary : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: (_selected.isEmpty || _submitted)
                ? null
                : () {
                    ref
                        .read(meetingProvider.notifier)
                        .submitAttendeeAvailability(
                          widget.code,
                          kMockStudentInfo.studentId,
                          _selected.toList(),
                        );
                    setState(() => _submitted = true);
                    showToast(
                      context,
                      'Availability submitted.',
                      type: ToastType.success,
                    );
                    Navigator.of(context).pop();
                    context.go('/calendar');
                  },
            child: const Text('Submit availability'),
          ),
        ),
      ],
    );
  }

  List<String> _suggestedSlots(MeetingData meeting) {
    final creatorSlots = meeting.attendeeAvailability[meeting.creatorId];
    if (creatorSlots != null && creatorSlots.isNotEmpty) return creatorSlots;
    return const ['09:00', '10:00', '13:00', '15:00'];
  }
}
