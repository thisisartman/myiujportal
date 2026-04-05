# Dashboard Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current 3-widget dashboard with a 4-widget layout: Upcoming Events (3–5 visible, scrollable), Quick Links grid, Alerts/News feed, and Digital ID. Add tappable tag chips to event cards that navigate to relevant pages.

**Architecture:** `DashboardPage` is rebuilt as an orchestrator of 4 new standalone widget files. Mock alerts data is added to `mock_data.dart`. A new `AlertItem` model is added. Event tag chips reuse `CalendarEvent` data to build navigable chips. No new providers needed — alerts use a static list from mock data; existing `calendarEventsProvider` is used for upcoming events.

**Tech Stack:** Flutter 3.41.4, flutter_riverpod ^2.6.1, go_router ^14.x

**Dependency:** Assumes `HoverCard` from UI Polish plan (`lib/widgets/common/hover_card.dart`) exists. If running before that plan, copy the `HoverCard` widget from that plan's Task 1.

---

## File Map

| Action | File | Change |
|--------|------|--------|
| Create | `lib/models/alert_item.dart` | `AlertItem` data model |
| Modify | `lib/data/mock_data.dart` | Add `kMockAlerts` list |
| Create | `lib/widgets/dashboard/upcoming_events_widget.dart` | 3–5 events, scrollable, tag chips |
| Create | `lib/widgets/dashboard/quick_links_widget.dart` | 4-button grid |
| Create | `lib/widgets/dashboard/alerts_widget.dart` | RSS-style news feed |
| Create | `lib/widgets/dashboard/digital_id_widget.dart` | Mock student ID card |
| Modify | `lib/pages/dashboard_page.dart` | Wire 4 new widgets, remove old ones |
| Delete | `lib/widgets/dashboard/up_next_card.dart` | Replaced by UpcomingEventsWidget |
| Delete | `lib/widgets/dashboard/calendar_widget.dart` | Replaced by new layout |

Note: The two deleted files are removed from disk and all imports updated. If you prefer to keep them, just stop importing them — but removing avoids confusion.

---

## Task 1: AlertItem model + mock data

**Files:**
- Create: `lib/models/alert_item.dart`
- Modify: `lib/data/mock_data.dart`

- [ ] **Step 1: Create AlertItem model**

```dart
// lib/models/alert_item.dart
import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, announcement }

extension AlertSeverityExt on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.info: return const Color(0xFF2563EB);
      case AlertSeverity.warning: return const Color(0xFFD97706);
      case AlertSeverity.announcement: return const Color(0xFF7C3AED);
    }
  }
  Color get bgColor {
    switch (this) {
      case AlertSeverity.info: return const Color(0xFFDBEAFE);
      case AlertSeverity.warning: return const Color(0xFFFEF3C7);
      case AlertSeverity.announcement: return const Color(0xFFF5F3FF);
    }
  }
  IconData get icon {
    switch (this) {
      case AlertSeverity.info: return Icons.info_outline;
      case AlertSeverity.warning: return Icons.warning_amber_outlined;
      case AlertSeverity.announcement: return Icons.campaign_outlined;
    }
  }
  String get label {
    switch (this) {
      case AlertSeverity.info: return 'Info';
      case AlertSeverity.warning: return 'Notice';
      case AlertSeverity.announcement: return 'Announcement';
    }
  }
}

class AlertItem {
  final String id;
  final String title;
  final String body;
  final String date;
  final String mailingList; // e.g. 'all-students', 'gsim-only'
  final AlertSeverity severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.mailingList,
    required this.severity,
  });
}
```

- [ ] **Step 2: Add mock alerts to mock_data.dart**

Add this import at the top of `lib/data/mock_data.dart`:
```dart
import '../models/alert_item.dart';
```

Add this list at the end of `lib/data/mock_data.dart`:

```dart
final List<AlertItem> kMockAlerts = [
  const AlertItem(
    id: 'a1',
    title: 'Library Extended Hours — Finals Week',
    body: 'The Matsushita Library (MLIC) will be open until midnight from Apr 20–30. Quiet study rooms bookable via OSS.',
    date: 'Apr 6',
    mailingList: 'all-students',
    severity: AlertSeverity.info,
  ),
  const AlertItem(
    id: 'a2',
    title: 'Course Registration Opens Apr 15',
    body: 'Spring term course registration opens at 9:00 AM on April 15. Log into the Academic Portal to submit your course selections. Contact OAA (oaa@iuj.ac.jp) with any questions.',
    date: 'Apr 5',
    mailingList: 'all-students',
    severity: AlertSeverity.announcement,
  ),
  const AlertItem(
    id: 'a3',
    title: 'GSIM Career Fair — Volunteer Sign-up',
    body: 'The GSIM Career Fair is on Apr 20. Students interested in volunteering at the event should sign up via the OSS portal by Apr 12.',
    date: 'Apr 4',
    mailingList: 'gsim-only',
    severity: AlertSeverity.info,
  ),
  const AlertItem(
    id: 'a4',
    title: 'Campus Shuttle Schedule Change (Golden Week)',
    body: 'The Urasa Station shuttle will run reduced service May 3–6 (Golden Week). Check the OGA notice board for the modified timetable.',
    date: 'Apr 3',
    mailingList: 'all-students',
    severity: AlertSeverity.warning,
  ),
  const AlertItem(
    id: 'a5',
    title: 'New Wi-Fi Access Points Installed in CNP',
    body: 'IT has upgraded wireless coverage in the CNP building. If you experience connectivity issues, contact helpdesk@iuj.ac.jp or Ext. 4222.',
    date: 'Apr 1',
    mailingList: 'all-students',
    severity: AlertSeverity.info,
  ),
];
```

- [ ] **Step 3: Analyze**

```bash
dart analyze lib/models/alert_item.dart lib/data/mock_data.dart
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/models/alert_item.dart lib/data/mock_data.dart
git commit -m "feat: AlertItem model and mock IUJ alerts/news data"
```

---

## Task 2: UpcomingEventsWidget with tag chips

**Files:**
- Create: `lib/widgets/dashboard/upcoming_events_widget.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/widgets/dashboard/upcoming_events_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_provider.dart';

class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    // Show events from today (date >= 6 in April mock) sorted by date then time
    final upcoming = events.where((e) => e.date >= 6).toList()
      ..sort((a, b) {
        if (a.date != b.date) return a.date.compareTo(b.date);
        return a.time.compareTo(b.time);
      });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text('Upcoming Events', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/calendar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('View all', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // First 4 events visible, rest in scrollable area
          if (upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No upcoming events.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            )
          else ...[
            // Fixed: show first 4
            ...upcoming.take(4).map((e) => _EventRow(event: e)),
            // Scrollable remainder
            if (upcoming.length > 4)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  child: Column(
                    children: upcoming.skip(4).map((e) => _EventRow(event: e)).toList(),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final CalendarEvent event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Type chip
              _chip(event.type.label, event.type.color, event.type.bgColor, () => context.go('/calendar')),
              const SizedBox(width: 6),
              Text('Apr ${event.date}  ${event.time}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 3),
          Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          // Detail chips — parse "CourseName | Code | Room" format
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _detailChips(context, event.detail),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailChips(BuildContext context, String detail) {
    // detail format: "InstructorName | CourseCode | Room"  or  "Venue | Organiser"
    final parts = detail.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return parts.map((part) {
      // Heuristic: if part looks like a course code (letters+digits), link to /wiki
      final isCourseCode = RegExp(r'^[A-Z]{2,4}\d{4}$').hasMatch(part.replaceAll('-', '').replaceAll(' ', ''));
      return _chip(part, const Color(0xFF6B7280), const Color(0xFFF3F4F6), () {
        if (isCourseCode) {
          context.go('/wiki'); // would ideally go to the specific course
        } else {
          context.go('/calendar');
        }
      });
    }).toList();
  }

  Widget _chip(String label, Color fg, Color bg, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/dashboard/upcoming_events_widget.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dashboard/upcoming_events_widget.dart
git commit -m "feat: UpcomingEventsWidget with tappable tag chips"
```

---

## Task 3: QuickLinksWidget

**Files:**
- Create: `lib/widgets/dashboard/quick_links_widget.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/widgets/dashboard/quick_links_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickLinksWidget extends StatelessWidget {
  const QuickLinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      _Link(Icons.calendar_today_outlined, 'Calendar', const Color(0xFF4F46E5), const Color(0xFFEEF2FF), '/calendar'),
      _Link(Icons.business_outlined, 'Facilities', const Color(0xFF059669), const Color(0xFFDCFCE7), '/facilities'),
      _Link(Icons.local_library_outlined, 'Wiki', const Color(0xFF0891B2), const Color(0xFFCFFAFE), '/wiki'),
      _Link(Icons.badge_outlined, 'Digital ID', const Color(0xFF7C3AED), const Color(0xFFF5F3FF), '/profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Links', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: links.map((l) => _LinkTile(link: l)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Link {
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final String path;
  const _Link(this.icon, this.label, this.fg, this.bg, this.path);
}

class _LinkTile extends StatefulWidget {
  final _Link link;
  const _LinkTile({super.key, required this.link});
  @override
  State<_LinkTile> createState() => _LinkTileState();
}

class _LinkTileState extends State<_LinkTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.link;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go(l.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? l.bg : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hovering ? l.fg : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(l.icon, color: l.fg, size: 18),
              const SizedBox(width: 8),
              Text(l.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _hovering ? l.fg : const Color(0xFF374151))),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/dashboard/quick_links_widget.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dashboard/quick_links_widget.dart
git commit -m "feat: QuickLinksWidget — 4 link grid with hover"
```

---

## Task 4: AlertsWidget (news feed)

**Files:**
- Create: `lib/widgets/dashboard/alerts_widget.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/widgets/dashboard/alerts_widget.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/alert_item.dart';

class AlertsWidget extends StatelessWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_none_outlined, size: 18, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                const Text('Alerts & News', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${kMockAlerts.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: kMockAlerts.map((alert) => _AlertRow(alert: alert)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatefulWidget {
  final AlertItem alert;
  const _AlertRow({required this.alert});
  @override
  State<_AlertRow> createState() => _AlertRowState();
}

class _AlertRowState extends State<_AlertRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: a.severity.bgColor, borderRadius: BorderRadius.circular(6)),
                    child: Icon(a.severity.icon, color: a.severity.color, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                            ),
                            Text(a.date, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: a.severity.bgColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(a.mailingList, style: TextStyle(fontSize: 10, color: a.severity.color, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16, color: const Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 0, 14, 10),
            child: Text(a.body, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/dashboard/alerts_widget.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dashboard/alerts_widget.dart
git commit -m "feat: AlertsWidget — expandable IUJ news/alerts feed"
```

---

## Task 5: DigitalIdWidget

**Files:**
- Create: `lib/widgets/dashboard/digital_id_widget.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/widgets/dashboard/digital_id_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DigitalIdWidget extends StatefulWidget {
  const DigitalIdWidget({super.key});
  @override
  State<DigitalIdWidget> createState() => _DigitalIdWidgetState();
}

class _DigitalIdWidgetState extends State<DigitalIdWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go('/profile'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovering
                  ? [const Color(0xFF4338CA), const Color(0xFF7C3AED)]
                  : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('IUJ-2026-0001', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('MBA · GSIM · Class of 2027', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.badge_outlined, color: Colors.white54, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/dashboard/digital_id_widget.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dashboard/digital_id_widget.dart
git commit -m "feat: DigitalIdWidget — student ID card linking to profile"
```

---

## Task 6: Rebuild DashboardPage

**Files:**
- Modify: `lib/pages/dashboard_page.dart`

- [ ] **Step 1: Replace the full file**

```dart
// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard/upcoming_events_widget.dart';
import '../widgets/dashboard/quick_links_widget.dart';
import '../widgets/dashboard/alerts_widget.dart';
import '../widgets/dashboard/digital_id_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Good morning, Student!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Wednesday, April 1, 2026',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        // Digital ID — full width
        const DigitalIdWidget(),
        const SizedBox(height: 16),

        // Main 2-column layout (or stacked on mobile)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Upcoming Events (wider)
                  const Expanded(flex: 5, child: UpcomingEventsWidget()),
                  const SizedBox(width: 16),
                  // Right: Quick Links + Alerts
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: const [
                        QuickLinksWidget(),
                        SizedBox(height: 16),
                        AlertsWidget(),
                      ],
                    ),
                  ),
                ],
              )
            : const Column(
                children: [
                  UpcomingEventsWidget(),
                  SizedBox(height: 16),
                  QuickLinksWidget(),
                  SizedBox(height: 16),
                  AlertsWidget(),
                ],
              ),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/pages/dashboard_page.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Remove old unused widget files**

```bash
git rm lib/widgets/dashboard/up_next_card.dart lib/widgets/dashboard/calendar_widget.dart
```

- [ ] **Step 4: Full project analyze**

```bash
dart analyze lib/
```
Expected: only pre-existing deprecated infos. Verify `up_next_card.dart` and `calendar_widget.dart` are not imported anywhere.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: dashboard redesign — 4-widget layout with ID card, upcoming events, quick links, alerts"
```
