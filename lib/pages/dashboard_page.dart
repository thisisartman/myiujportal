// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard/alerts_widget.dart';
import '../widgets/dashboard/digital_id_widget.dart';
import '../widgets/dashboard/group_meeting_polls_card.dart';
import '../widgets/dashboard/library_loans_card.dart';
import '../widgets/dashboard/quick_links_widget.dart';
import '../widgets/dashboard/dashboard_event_utils.dart';
import '../widgets/dashboard/today_timeline_card.dart';
import '../widgets/dashboard/up_next_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(dashboardSettingsProvider);
    final events = ref.watch(calendarEventsProvider);
    final todayEvents = _todayEvents(events);
    final upNext = _upNextEvent(todayEvents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GreetingSection(settings: settings),
        const SizedBox(height: 18),
        _DashboardGrid(
          cols: int.tryParse(settings.columnCount) ?? 3,
          upNext: settings.showUpNext ? UpNextCard(event: upNext) : null,
          idCard: settings.showIdCard ? const DigitalIdWidget() : null,
          timeline: settings.showTimeline
              ? TodayTimelineCard(events: todayEvents)
              : null,
          alerts: settings.showAlerts ? const AlertsWidget() : null,
          quickLinks: settings.showQuickLinks
              ? QuickLinksWidget(style: settings.quickLinkStyle)
              : null,
          library: settings.showLibrary ? const LibraryLoansCard() : null,
          polls: settings.showPolls ? const GroupMeetingPollsCard() : null,
        ),
      ],
    );
  }

  List<CalendarEvent> _todayEvents(List<CalendarEvent> events) {
    final today = DateTime.now();
    final exact = events
        .where((event) => isDashboardEventOnDate(event, today))
        .toList();
    final source = exact.isEmpty ? getTodayEvents() : exact;
    return [...source]..sort((a, b) => a.time.compareTo(b.time));
  }

  CalendarEvent? _upNextEvent(List<CalendarEvent> events) {
    final now = DateTime.now();
    for (final event in events) {
      if (dashboardEventDateTime(event).isAfter(now)) return event;
    }
    return events.isEmpty ? null : events.last;
  }
}

class _GreetingSection extends ConsumerWidget {
  final DashboardSettings settings;

  const _GreetingSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greetingFor(now)}, ${kMockStudentInfo.givenName}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const _TermBadge(),
                const _Dot(),
                Text(
                  DateFormat('EEEE, MMMM d · HH:mm').format(now),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const _Dot(),
                Text(
                  kMockDashboardWeather,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );

        final controls = _DashboardControls(settings: settings);
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [left, const SizedBox(height: 14), controls],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            controls,
          ],
        );
      },
    );
  }

  String _greetingFor(DateTime time) {
    if (time.hour < 12) return 'Good morning';
    if (time.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DashboardControls extends ConsumerWidget {
  final DashboardSettings settings;

  const _DashboardControls({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardSettingsProvider.notifier);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '1', label: Text('1')),
            ButtonSegment(value: '2', label: Text('2')),
            ButtonSegment(value: '3', label: Text('3')),
          ],
          selected: {settings.columnCount},
          showSelectedIcon: false,
          onSelectionChanged: (value) => notifier.setColumnCount(value.first),
        ),
        PopupMenuButton<String>(
          tooltip: 'Quick link style',
          onSelected: notifier.setQuickLinkStyle,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'icon-only', child: Text('Icon only')),
            PopupMenuItem(value: 'icon-label', child: Text('Icon + label')),
            PopupMenuItem(value: 'cards', child: Text('Cards')),
          ],
          child: _ControlPill(
            icon: Icons.grid_view_outlined,
            label: settings.quickLinkStyle,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Dashboard widgets',
          onSelected: notifier.toggle,
          itemBuilder: (context) => [
            _toggleItem('upNext', 'Up next', settings.showUpNext),
            _toggleItem('timeline', 'Timeline', settings.showTimeline),
            _toggleItem('alerts', 'Alerts', settings.showAlerts),
            _toggleItem('quickLinks', 'Quick links', settings.showQuickLinks),
            _toggleItem('idCard', 'Digital ID', settings.showIdCard),
            _toggleItem('library', 'Library', settings.showLibrary),
            _toggleItem('polls', 'Polls', settings.showPolls),
          ],
          child: const _ControlPill(
            icon: Icons.tune_outlined,
            label: 'Widgets',
          ),
        ),
      ],
    );
  }

  CheckedPopupMenuItem<String> _toggleItem(
    String value,
    String label,
    bool checked,
  ) {
    return CheckedPopupMenuItem(
      value: value,
      checked: checked,
      child: Text(label),
    );
  }
}

class _ControlPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ControlPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ruleSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.tealInk),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermBadge extends StatelessWidget {
  const _TermBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tealTint2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.tealInk,
          ),
          SizedBox(width: 5),
          Text(
            'Spring 2026 · Week 6',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.tealInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final int cols;
  final Widget? upNext;
  final Widget? idCard;
  final Widget? timeline;
  final Widget? alerts;
  final Widget? quickLinks;
  final Widget? library;
  final Widget? polls;

  const _DashboardGrid({
    required this.cols,
    this.upNext,
    this.idCard,
    this.timeline,
    this.alerts,
    this.quickLinks,
    this.library,
    this.polls,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final canUse3 = width >= 1100 && cols >= 3;
        final canUse2 = width >= 768 && cols >= 2;
        if (canUse3) return _threeColumn();
        if (canUse2) return _twoColumn(width);
        return _oneColumn();
      },
    );
  }

  Widget _threeColumn() {
    final left = _withVerticalGaps([upNext, timeline]);
    final right = _withVerticalGaps([idCard, alerts, polls]);
    final bottom = _withHorizontalGaps([quickLinks, library]);
    return Column(
      children: [
        if (left.isNotEmpty || right.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (left.isNotEmpty)
                Expanded(flex: 8, child: Column(children: left)),
              if (left.isNotEmpty && right.isNotEmpty)
                const SizedBox(width: 16),
              if (right.isNotEmpty)
                Expanded(flex: 4, child: Column(children: right)),
            ],
          ),
        if (bottom.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: bottom),
        ],
      ],
    );
  }

  Widget _twoColumn(double width) {
    final full = _withVerticalGaps([upNext, idCard, timeline, alerts]);
    final halfItems = [quickLinks, library, polls].whereType<Widget>().toList();
    return Column(
      children: [
        ...full,
        if (halfItems.isNotEmpty) ...[
          if (full.isNotEmpty) const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: halfItems
                .map((child) => SizedBox(width: (width - 16) / 2, child: child))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _oneColumn() {
    return Column(
      children: _withVerticalGaps([
        upNext,
        idCard,
        timeline,
        alerts,
        quickLinks,
        library,
        polls,
      ]),
    );
  }

  List<Widget> _withVerticalGaps(List<Widget?> widgets) {
    final visible = widgets.whereType<Widget>().toList();
    return [
      for (var i = 0; i < visible.length; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        visible[i],
      ],
    ];
  }

  List<Widget> _withHorizontalGaps(List<Widget?> widgets) {
    final visible = widgets.whereType<Widget>().toList();
    return [
      for (var i = 0; i < visible.length; i++) ...[
        if (i > 0) const SizedBox(width: 16),
        Expanded(child: visible[i]),
      ],
    ];
  }
}
