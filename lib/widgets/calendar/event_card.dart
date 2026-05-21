import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../dashboard/dashboard_event_utils.dart';
import 'event_detail_modal.dart';

class EventCard extends StatelessWidget {
  final CalendarEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final e = event;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => AppModal.show(
          context,
          title: e.title,
          child: EventDetailModal(event: e),
        ),
        child: Container(
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
                    if (e.detail.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _detailChips(context, e),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _detailChips(BuildContext context, CalendarEvent e) {
    final parts = e.detail
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.map((part) {
      final normalized = part.replaceAll('-', '').replaceAll(' ', '');
      final isCourseCode = RegExp(r'^[A-Z]{2,5}\d{4,5}$').hasMatch(normalized);
      final isProfessor =
          RegExp(r'^[A-Z][A-Za-z .-]+$').hasMatch(part) &&
          !part.contains('Hall') &&
          !part.contains('Cafeteria');
      final isFacility = RegExp(
        r'(G\.|P\.|Hall|Cafeteria|Library|Gym|Room)',
      ).hasMatch(part);

      return _Chip(
        label: part,
        onTap: () {
          if (isCourseCode) {
            context.go(courseWikiRoute(normalized));
          } else if (isProfessor) {
            context.go('/facilities/directory?query=${Uri.encodeComponent(part)}');
          } else if (isFacility) {
            context.go(roomWikiRoute(part));
          } else {
            context.go('/calendar?filter=${e.type.name}');
          }
        },
      );
    }).toList();
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

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }
}
