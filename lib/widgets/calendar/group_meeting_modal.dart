import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';
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
  bool _repeatWeekly = false;
  String? _generatedCode;

  // 5.8: month navigation state
  late DateTime _viewMonth;

  // 5.9: TextField for duration
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _durationController = TextEditingController(text: '$_durationMinutes');
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

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

  // 5.8: date step with month navigation
  Widget _dateStep() {
    final now = DateTime.now();
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final offset = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday - 1;
    final isCurrentMonth =
        _viewMonth.year == now.year && _viewMonth.month == now.month;

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
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: isCurrentMonth
                  ? null
                  : () => setState(() {
                        _viewMonth = DateTime(
                          _viewMonth.year,
                          _viewMonth.month - 1,
                        );
                        _date = null;
                      }),
              icon: const Icon(Icons.chevron_left, size: 18),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat('MMMM yyyy').format(_viewMonth),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () => setState(() {
                _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
                _date = null;
              }),
              icon: const Icon(Icons.chevron_right, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
                selected: _date?.day == day &&
                    _date?.month == _viewMonth.month &&
                    _date?.year == _viewMonth.year,
                disabled: isCurrentMonth && day <= now.day,
                onTap: () => setState(
                  () => _date = DateTime(_viewMonth.year, _viewMonth.month, day),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 5.9: time step with TextField for duration
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
                  : () => setState(() {
                        _durationMinutes -= 10;
                        _durationController.text = '$_durationMinutes';
                      }),
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 72,
              child: TextField(
                controller: _durationController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed >= 10) {
                    // snap to nearest 10-min multiple
                    final snapped = (parsed / 10).round() * 10;
                    setState(() => _durationMinutes = snapped.clamp(10, 480));
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _durationMinutes += 10;
                _durationController.text = '$_durationMinutes';
              }),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            _durationLabel,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // 5.10: simple weekly toggle
  Widget _repetitionStep() {
    return SwitchListTile(
      title: const Text(
        'Repeat weekly',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      value: _repeatWeekly,
      onChanged: (v) => setState(() => _repeatWeekly = v),
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  // 5.11A: summary step with styled card
  Widget _summaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meeting summary',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${DateFormat('MMMM d, yyyy').format(_date!)}'),
              const SizedBox(height: 4),
              Text('Start: ${_startTime.format(context)}'),
              const SizedBox(height: 4),
              Text('Duration: $_durationLabel'),
              const SizedBox(height: 4),
              Text('Repeat: ${_repeatWeekly ? 'Weekly' : 'None'}'),
            ],
          ),
        ),
      ],
    );
  }

  String get _durationLabel {
    if (_durationMinutes < 60) return '$_durationMinutes min';
    final h = _durationMinutes ~/ 60;
    final m = _durationMinutes % 60;
    return m > 0 ? '$h hr $m min' : '$h hr';
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
      return;
    }

    // 5.11B: generate code, add CalendarEvent, navigate
    final code = _generateCode();
    final meeting = MeetingData(
      code: code,
      creatorId: kMockStudentInfo.studentId,
      status: 'pending',
      date: _date!,
      durationMinutes: _durationMinutes,
      repetition: _repeatWeekly ? 'Weekly' : 'None',
      totalInvitees: 4,
      attendeeAvailability: {
        kMockStudentInfo.studentId: [_startTime.format(context)],
      },
    );
    ref.read(meetingProvider.notifier).addMeeting(meeting);

    final notifier = ref.read(calendarEventsProvider.notifier);
    notifier.addEvent(
      CalendarEvent(
        id: notifier.nextId,
        type: CalendarEventType.event,
        year: _date!.year,
        month: _date!.month,
        date: _date!.day,
        time: _startTime.format(context),
        title: 'Group Meeting',
        detail: code,
        meetingCode: code,
      ),
    );

    setState(() => _generatedCode = code);

    // Pop modal then navigate to meeting page
    if (mounted) {
      Navigator.of(context).pop();
      context.go('/meeting/$code');
    }
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
