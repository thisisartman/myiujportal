import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';

class EventDetailModal extends ConsumerWidget {
  final CalendarEvent event;

  const EventDetailModal({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: event.type.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                event.type.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: event.type.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              event.time,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: _detailChips(context)),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
              onPressed: () => showEditEventModal(context, ref, event),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _detailChips(BuildContext context) {
    final parts = event.detail
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.map((part) {
      final normalized = part.replaceAll('-', '').replaceAll(' ', '');
      final isCourse = RegExp(r'^[A-Z]{2,5}\d{4,5}$').hasMatch(normalized);
      final isLocation = RegExp(
        r'(G\.|P\.|Hall|Cafeteria|Library|Gym|Room)',
      ).hasMatch(part);
      final isProfessor =
          !isCourse && !isLocation && RegExp(r'[A-Za-z]').hasMatch(part);

      return _DetailChip(
        label: part,
        onTap: () {
          Navigator.of(context).pop();
          if (isCourse) {
            context.go('/wiki/course-${normalized.toLowerCase()}');
          } else if (isLocation) {
            context.go('/facilities/room-booking');
          } else if (isProfessor) {
            context.go('/facilities/directory');
          }
        },
      );
    }).toList();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('Delete "${event.title}" from your calendar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(calendarEventsProvider.notifier).deleteEvent(event.id);
    Navigator.of(context).pop();
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DetailChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

void showEditEventModal(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent event,
) {
  final titleController = TextEditingController(text: event.title);
  final detailController = TextEditingController(text: event.detail);
  final timeController = TextEditingController(text: event.time);
  var selectedType = event.type;

  AppModal.show(
    context,
    title: 'Edit Event',
    child: StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<CalendarEventType>(
            initialValue: selectedType,
            items: CalendarEventType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: (value) => setState(() => selectedType = value!),
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: detailController,
            decoration: const InputDecoration(
              labelText: 'Detail',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: 'Time (HH:MM)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref
                      .read(calendarEventsProvider.notifier)
                      .updateEvent(
                        event.copyWith(
                          type: selectedType,
                          title: titleController.text,
                          detail: detailController.text,
                          time: timeController.text,
                        ),
                      );
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
