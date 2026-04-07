// lib/widgets/calendar/group_meeting_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/app_modal.dart';
import '../../theme/app_colors.dart';

class GroupMeetingModal extends StatefulWidget {
  const GroupMeetingModal({super.key});

  static void show(BuildContext context) {
    AppModal.show(context, title: 'Schedule Group Meeting', child: const GroupMeetingModal());
  }

  @override
  State<GroupMeetingModal> createState() => _GroupMeetingModalState();
}

class _GroupMeetingModalState extends State<GroupMeetingModal> {
  // April 2026 — days 7–30
  final Set<int> _selectedDays = {};
  final Set<String> _selectedSlots = {};
  String? _generatedLink;

  static const _slots = [
    '09:00 – 10:30', '10:40 – 12:10', '13:15 – 14:45',
    '14:55 – 16:25', '16:30 – 18:00', '18:15 – 19:45',
  ];

  @override
  Widget build(BuildContext context) {
    if (_generatedLink != null) return _linkView();
    return _selectionView();
  }

  Widget _selectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Select days you are free', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        // Day grid (remaining April days)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(24, (i) => i + 7).map((day) {
            final selected = _selectedDays.contains(day);
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (selected) { _selectedDays.remove(day); } else { _selectedDays.add(day); }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('2. Select available time slots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ..._slots.map((slot) {
          final selected = _selectedSlots.contains(slot);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (selected) { _selectedSlots.remove(slot); } else { _selectedSlots.add(slot); }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 14, color: selected ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(slot, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? AppColors.primary : AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: _selectedDays.isEmpty || _selectedSlots.isEmpty ? null : _generateLink,
              child: const Text('Generate Link'),
            ),
          ],
        ),
      ],
    );
  }

  void _generateLink() {
    final days = (_selectedDays.toList()..sort()).join(',');
    final slots = _selectedSlots.length;
    setState(() {
      _generatedLink = 'https://myiuj.iuj.ac.jp/meeting?days=$days&slots=$slots&host=IUJ-2026-0001';
    });
  }

  Widget _linkView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.primary, size: 48),
        const SizedBox(height: 12),
        const Text('Meeting link created!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Share this link with your group. They can select their available slots on top of yours.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(child: Text(_generatedLink!, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: _generatedLink!)),
                  child: const Icon(Icons.copy_outlined, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
