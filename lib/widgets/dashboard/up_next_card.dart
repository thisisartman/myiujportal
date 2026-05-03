import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../providers/directory_provider.dart';
import '../../theme/app_colors.dart';
import '../common/dashboard_card.dart';
import 'dashboard_event_utils.dart';

class UpNextCard extends ConsumerWidget {
  final CalendarEvent? event;

  const UpNextCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = event;
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.bolt_outlined,
        text: 'Up next',
      ),
      actionLabel: 'Open calendar',
      onAction: () => context.go('/calendar'),
      flushBody: true,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.tealTint2, AppColors.surface],
            stops: [0.0, 0.62],
          ),
          border: Border(top: BorderSide(color: AppColors.primary, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: e == null ? _emptyState() : _eventState(context, ref, e),
      ),
    );
  }

  Widget _emptyState() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No remaining schedule items today',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Use this space to review alerts, library loans, and meeting polls.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _eventState(BuildContext context, WidgetRef ref, CalendarEvent e) {
    final meta = parseDashboardEventMeta(e.detail);
    final minutes = _minutesUntil(e.time);
    final countdown = minutes <= 0 ? 'now' : 'in $minutes min';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _LivePulse(),
            const SizedBox(width: 8),
            Text(
              'Up next · $countdown',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.tealInk,
              ),
            ),
            const Spacer(),
            Text(
              e.time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          e.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (meta.course != null)
              _MetaChip(
                label: meta.course!,
                icon: Icons.menu_book_outlined,
                solid: true,
                onTap: () => context.go(
                  '/wiki/course-${dashboardCourseId(meta.course!)}',
                ),
              ),
            if (meta.professor != null)
              _MetaChip(
                label: meta.professor!,
                icon: Icons.person_outline,
                onTap: () {
                  ref.read(directorySearchProvider.notifier).state =
                      meta.professor!;
                  ref.read(directoryFilterProvider.notifier).state = 'Faculty';
                  context.go('/facilities/directory');
                },
              ),
            if (meta.room != null)
              _MetaChip(
                label: meta.room!,
                icon: Icons.location_on_outlined,
                onTap: () => context.go('/facilities/room-booking'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/facilities/room-booking'),
              icon: const Icon(Icons.explore_outlined, size: 16),
              label: const Text('Directions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.tealInk,
                side: const BorderSide(color: AppColors.rule),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => context.go('/calendar'),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Open class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _minutesUntil(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? now.hour,
      int.tryParse(parts[1]) ?? now.minute,
    );
    return target.difference(now).inMinutes;
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse();

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool solid;
  final VoidCallback onTap;

  const _MetaChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: solid ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: solid ? AppColors.primary : AppColors.rule,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: solid ? Colors.white : AppColors.tealInk,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: solid ? Colors.white : AppColors.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
