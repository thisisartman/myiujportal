import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/meeting_provider.dart';
import '../../theme/app_colors.dart';
import '../common/toast_overlay.dart';

class MeetingCreatorModal extends ConsumerStatefulWidget {
  final String code;
  const MeetingCreatorModal({super.key, required this.code});

  @override
  ConsumerState<MeetingCreatorModal> createState() =>
      _MeetingCreatorModalState();
}

class _MeetingCreatorModalState extends ConsumerState<MeetingCreatorModal> {
  String? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final meeting = ref.watch(meetingProvider)[widget.code];
    if (meeting == null) return const SizedBox.shrink();

    final proposed = _suggestedSlots(meeting);
    final respondedCount =
        meeting.attendeeAvailability.length - 1; // exclude creator
    final total = meeting.totalInvitees;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: respondedCount >= total
                ? AppColors.successLight
                : AppColors.warningLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$respondedCount / $total responded',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: respondedCount >= total
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Select the final time slot:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: _selectedSlot,
          onChanged: (v) => setState(() => _selectedSlot = v),
          child: Column(
            children: proposed.map((slot) {
              final respondents = meeting.attendeeAvailability.entries
                  .where(
                    (e) =>
                        e.key != meeting.creatorId && e.value.contains(slot),
                  )
                  .map((e) => e.key)
                  .toList();

              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: slot,
                title: Text(
                  slot,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: respondents.isEmpty
                    ? const Text(
                        'No responses yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: respondents
                              .map(
                                (id) => CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    _initials(id),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _selectedSlot == null
                ? null
                : () {
                    ref
                        .read(meetingProvider.notifier)
                        .confirmMeeting(widget.code);
                    Navigator.of(context).pop();
                    showToast(
                      context,
                      'Group meeting confirmed. Calendar invites sent to all attendees.',
                      type: ToastType.success,
                    );
                  },
            child: const Text('Confirm meeting'),
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

  String _initials(String id) {
    const known = {
      'IUJ-2026-0001': 'SB',
      'IUJ-2026-0042': 'YT',
      'IUJ-2026-0078': 'MS',
      'IUJ-2025-0134': 'AA',
      'IUJ-2025-0099': 'LW',
      'IUJ-2027-0142': 'AT',
    };
    return known[id] ?? id.substring(0, 2).toUpperCase();
  }
}
