import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';
import '../common/app_modal.dart';

class EventCard extends ConsumerStatefulWidget {
  final CalendarEvent event;
  const EventCard({super.key, required this.event});

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        decoration: BoxDecoration(
          color: e.type.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: e.type.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent bar
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: e.type.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP ROW: type tag + time + action buttons (always visible)
                  Row(
                    children: [
                      // Type tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: e.type.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.type.label,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: e.type.color),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(e.time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const Spacer(),
                      // Action buttons — always present, animate opacity on hover
                      AnimatedOpacity(
                        opacity: _hovering ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 150),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28, height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                color: const Color(0xFF6B7280),
                                onPressed: () => _showEditModal(context, e),
                              ),
                            ),
                            SizedBox(
                              width: 28, height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline, size: 14),
                                color: const Color(0xFFEF4444),
                                onPressed: () => ref.read(calendarEventsProvider.notifier).deleteEvent(e.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  Text(e.detail, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, CalendarEvent event) {
    final titleController = TextEditingController(text: event.title);
    final detailController = TextEditingController(text: event.detail);
    final timeController = TextEditingController(text: event.time);
    CalendarEventType selectedType = event.type;

    AppModal.show(
      context,
      title: 'Edit Event',
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CalendarEventType>(
              value: selectedType,
              items: CalendarEventType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label),
              )).toList(),
              onChanged: (v) => setState(() => selectedType = v!),
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailController,
              decoration: const InputDecoration(labelText: 'Detail', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)', border: OutlineInputBorder()),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    ref.read(calendarEventsProvider.notifier).updateEvent(
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
}
