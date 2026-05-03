import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/meeting_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';

class GroupMeetingModal extends ConsumerStatefulWidget {
  const GroupMeetingModal({super.key});

  static void show(BuildContext context) {
    AppModal.show(
      context,
      title: 'Schedule Group Meeting',
      child: const GroupMeetingModal(),
    );
  }

  @override
  ConsumerState<GroupMeetingModal> createState() => _GroupMeetingModalState();
}

class _GroupMeetingModalState extends ConsumerState<GroupMeetingModal> {
  int _step = 1;
  DateTime? _date;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationMinutes = 60;
  String _repetition = 'None';
  String? _generatedCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _step / 4,
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 16),
        if (_step == 1) _dateStep(),
        if (_step == 2) _timeStep(),
        if (_step == 3) _repetitionStep(),
        if (_step == 4) _summaryStep(),
        const SizedBox(height: 16),
        if (_generatedCode == null)
          Row(
            children: [
              if (_step > 1)
                TextButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _canContinue ? _next : null,
                child: Text(_step == 4 ? 'Generate link' : 'Next'),
              ),
            ],
          ),
      ],
    );
  }

  bool get _canContinue => _step != 1 || _date != null;

  Widget _dateStep() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final offset = DateTime(now.year, now.month, 1).weekday - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a meeting date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: [
            for (var i = 0; i < offset; i++) const SizedBox(),
            for (var day = 1; day <= daysInMonth; day++)
              _MeetingDayCell(
                day: day,
                selected: _date?.day == day,
                disabled: day <= now.day,
                onTap: () =>
                    setState(() => _date = DateTime(now.year, now.month, day)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _timeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose time and duration',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.access_time, size: 16),
          label: Text(_startTime.format(context)),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _startTime,
            );
            if (picked != null) setState(() => _startTime = picked);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _durationMinutes <= 10
                  ? null
                  : () => setState(() => _durationMinutes -= 10),
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _durationLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _durationMinutes += 10),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _repetitionStep() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'None', label: Text('None')),
        ButtonSegment(value: 'Weekly', label: Text('Weekly')),
        ButtonSegment(value: 'Bi-weekly', label: Text('Bi-weekly')),
      ],
      selected: {_repetition},
      onSelectionChanged: (selection) {
        setState(() => _repetition = selection.first);
      },
    );
  }

  Widget _summaryStep() {
    final code = _generatedCode;
    final url = code == null ? null : '/meeting/$code';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meeting summary',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Date: ${_date!.year}-${_date!.month}-${_date!.day}'),
        Text('Start: ${_startTime.format(context)}'),
        Text('Duration: $_durationLabel'),
        Text('Repetition: $_repetition'),
        if (url != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(url, overflow: TextOverflow.ellipsis)),
                IconButton(
                  onPressed: () => Clipboard.setData(ClipboardData(text: url)),
                  icon: const Icon(Icons.copy_outlined, size: 18),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String get _durationLabel {
    if (_durationMinutes < 60) return '$_durationMinutes minutes';
    final hours = _durationMinutes ~/ 60;
    final minutes = _durationMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
      return;
    }

    final code = _generateCode();
    ref
        .read(meetingProvider.notifier)
        .addMeeting(
          MeetingData(
            code: code,
            creatorId: 'IUJ-2026-0001',
            status: 'pending',
            date: _date!,
            durationMinutes: _durationMinutes,
            repetition: _repetition,
            attendeeAvailability: {
              'IUJ-2026-0001': [_startTime.format(context)],
            },
          ),
        );
    setState(() => _generatedCode = code);
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

class _MeetingDayCell extends StatelessWidget {
  final int day;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _MeetingDayCell({
    required this.day,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (disabled ? Colors.transparent : AppColors.primaryLight),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : (disabled ? AppColors.textMuted : AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
