import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/meeting_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/toast_overlay.dart';

class MeetingPage extends ConsumerWidget {
  final String code;

  const MeetingPage({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meeting = ref.watch(meetingProvider)[code];
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

    final isCreator = meeting.creatorId == 'IUJ-2026-0001';
    final slots = _suggestedSlots(meeting);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting $code',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${meeting.date.year}-${meeting.date.month}-${meeting.date.day} - ${meeting.durationMinutes} minutes - ${meeting.repetition}',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Availability',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots
                    .map(
                      (slot) => _AvailabilityChip(
                        slot: slot,
                        count: meeting.attendeeAvailability.values
                            .where((values) => values.contains(slot))
                            .length,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref
                      .read(meetingProvider.notifier)
                      .submitAttendeeAvailability(
                        code,
                        'attendee-${DateTime.now().millisecondsSinceEpoch}',
                        slots.take(2).toList(),
                      );
                  showToast(
                    context,
                    'Availability submitted.',
                    type: ToastType.success,
                  );
                },
                child: const Text('Submit availability'),
              ),
              if (isCreator) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  onPressed: () {
                    ref.read(meetingProvider.notifier).confirmMeeting(code);
                    showToast(
                      context,
                      'Google Calendar invites sent to all attendees.',
                      type: ToastType.success,
                    );
                  },
                  child: const Text('Confirm group meeting'),
                ),
              ],
            ],
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

class _AvailabilityChip extends StatelessWidget {
  final String slot;
  final int count;

  const _AvailabilityChip({required this.slot, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slot,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
