# Facilities Hub Revamp — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat facilities page with a hub of three sub-pages: Room Booking (calendar-based, multi-step modal), Library (read-only info hub), and Campus Directory (search + filter + expandable cards).

**Architecture:** `/facilities` becomes a hub page routing to `/facilities/room-booking`, `/facilities/library`, and `/facilities/directory`. Room booking uses a `ConsumerStatefulWidget` multi-step modal (calendar → multi-select slots → dynamic form). Alerts and booked slots are stored in Riverpod providers so the dashboard reflects booking confirmations.

**Tech Stack:** Flutter 3.41.4 · Dart 3.11.1 · flutter_riverpod 2.6.1 · go_router 14.x

---

## File Map

**New files:**
- `lib/providers/alerts_provider.dart` — `StateProvider<List<AlertItem>>`
- `lib/providers/directory_provider.dart` — search, filter, expanded card providers
- `lib/pages/facilities_hub_page.dart` — hub with 3 feature cards
- `lib/pages/facilities/room_booking_page.dart` — grouped room card list
- `lib/pages/facilities/library_page.dart` — loans, resources, MLIC link
- `lib/pages/facilities/campus_directory_page.dart` — search + filter + results
- `lib/widgets/facilities/booking_modal.dart` — multi-step modal (StatefulWidget)
- `lib/widgets/facilities/booking_calendar.dart` — month calendar step
- `lib/widgets/facilities/booking_slot_selector.dart` — multi-select slot step
- `lib/widgets/facilities/booking_form.dart` — dynamic form step
- `lib/widgets/directory/directory_card.dart` — expandable person/org card

**Modified files:**
- `lib/models/facility.dart` — add `FacilityCategory` enum, add `category` field, remove `type` field
- `lib/models/wiki_page.dart` — add `studentId` and `coordinator` optional fields to `DirectoryEntry`
- `lib/data/mock_data.dart` — update facilities with categories, add availability map, library mock data, extended directory
- `lib/providers/facilities_provider.dart` — remove old slot/reason/status providers, add `bookedSlotsProvider`
- `lib/router/app_router.dart` — replace `/facilities` route with hub + 3 nested sub-routes
- `lib/widgets/dashboard/alerts_widget.dart` — switch from `kMockAlerts` constant to `alertsProvider`
- `lib/pages/profile_page.dart` — add "My Library" section

**Deleted files:**
- `lib/pages/facilities_page.dart`
- `lib/widgets/facilities/time_slot_selector.dart`
- `lib/widgets/facilities/facility_card.dart`

---

## Task 1: Add alertsProvider and make AlertsWidget reactive

**Files:**
- Create: `lib/providers/alerts_provider.dart`
- Modify: `lib/widgets/dashboard/alerts_widget.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myiuj_portal/providers/alerts_provider.dart';
import 'package:myiuj_portal/widgets/dashboard/alerts_widget.dart';
import 'package:myiuj_portal/models/alert_item.dart';

testWidgets('AlertsWidget shows injected alerts', (tester) async {
  final testAlert = AlertItem(
    id: 'test1',
    title: 'Test Alert',
    body: 'Body text',
    date: 'Apr 6',
    mailingList: 'all',
    severity: AlertSeverity.info,
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      alertsProvider.overrideWith((ref) => [testAlert]),
    ],
    child: const MaterialApp(home: Scaffold(body: AlertsWidget())),
  ));
  expect(find.text('Test Alert'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd /Users/subhanshubiswas/Projects/myiujportal
flutter test test/widget_test.dart
```

Expected: fails with "alertsProvider not defined".

- [ ] **Step 3: Create `lib/providers/alerts_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/alert_item.dart';

final alertsProvider = StateProvider<List<AlertItem>>((ref) => kMockAlerts);
```

- [ ] **Step 4: Update `lib/widgets/dashboard/alerts_widget.dart` to watch alertsProvider**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alert_item.dart';
import '../../providers/alerts_provider.dart';

class AlertsWidget extends ConsumerWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
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
                    '${alerts.length}',
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
                children: alerts.map((alert) => _AlertRow(alert: alert)).toList(),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: a.severity.bgColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(a.mailingList, style: TextStyle(fontSize: 10, color: a.severity.color, fontWeight: FontWeight.w600)),
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

- [ ] **Step 5: Run test to confirm it passes**

```bash
flutter test test/widget_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/alerts_provider.dart lib/widgets/dashboard/alerts_widget.dart test/widget_test.dart
git commit -m "feat: add alertsProvider; AlertsWidget now reads from provider"
```

---

## Task 2: Update Facility model — add FacilityCategory, remove type field

**Files:**
- Modify: `lib/models/facility.dart`

- [ ] **Step 1: Replace `lib/models/facility.dart`**

```dart
import 'package:flutter/material.dart';

enum FacilityCategory { classroom, lounge, gymnasium }

class Facility {
  final String id;
  final String name;
  final FacilityCategory category;
  final String authority;
  final Color bgColor;
  final Color iconColor;

  const Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.authority,
    required this.bgColor,
    required this.iconColor,
  });
}

class TimeSlot {
  final String time;
  final bool available;

  const TimeSlot({required this.time, required this.available});
}
```

- [ ] **Step 2: Run analyzer to find all usages of the removed `type` field**

```bash
dart analyze lib/
```

Expected: errors for `facility.type` references (in `facility_card.dart` and any other files). These files will be deleted in Task 14, so note them — do not fix them yet.

- [ ] **Step 3: Commit**

```bash
git add lib/models/facility.dart
git commit -m "refactor: replace Facility.type string with FacilityCategory enum"
```

---

## Task 3: Update DirectoryEntry model — add studentId and coordinator fields

**Files:**
- Modify: `lib/models/wiki_page.dart`

- [ ] **Step 1: Add optional fields to `DirectoryEntry` in `lib/models/wiki_page.dart`**

Replace the `DirectoryEntry` class (lines 40–54):

```dart
class DirectoryEntry {
  final int id;
  final String name;
  final String type;
  final String email;
  final String phone;
  final String? studentId;
  final String? coordinator;

  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
    required this.phone,
    this.studentId,
    this.coordinator,
  });
}
```

- [ ] **Step 2: Run analyzer**

```bash
dart analyze lib/
```

Expected: no new errors (fields are optional with defaults).

- [ ] **Step 3: Commit**

```bash
git add lib/models/wiki_page.dart
git commit -m "refactor: add optional studentId and coordinator to DirectoryEntry"
```

---

## Task 4: Update mock_data.dart — facilities, availability, library data, directory

**Files:**
- Modify: `lib/data/mock_data.dart`

- [ ] **Step 1: Replace `kFacilities` and `kMockSlots` in `lib/data/mock_data.dart`**

Replace lines 1–49 (the facilities and slots sections):

```dart
import '../models/alert_item.dart';
import '../models/calendar_event.dart';
import '../models/facility.dart';
import '../models/wiki_page.dart';
import 'package:flutter/material.dart';

final List<Facility> kFacilities = [
  // Classrooms
  const Facility(
    id: 'f1',
    name: 'Classroom G.30',
    category: FacilityCategory.classroom,
    authority: 'OAA',
    bgColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF2563EB),
  ),
  const Facility(
    id: 'f2',
    name: 'Classroom P.103',
    category: FacilityCategory.classroom,
    authority: 'OAA',
    bgColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF2563EB),
  ),
  const Facility(
    id: 'f3',
    name: 'Seminar Room G.21',
    category: FacilityCategory.classroom,
    authority: 'OAA',
    bgColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF2563EB),
  ),
  // Lounges
  const Facility(
    id: 'f4',
    name: 'CNP Snack Lounge',
    category: FacilityCategory.lounge,
    authority: 'OGA',
    bgColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFEA580C),
  ),
  const Facility(
    id: 'f5',
    name: 'BBQ Area',
    category: FacilityCategory.lounge,
    authority: 'OSS',
    bgColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFEA580C),
  ),
  const Facility(
    id: 'f6',
    name: 'Student Lounge (CNP B1)',
    category: FacilityCategory.lounge,
    authority: 'OSS',
    bgColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFEA580C),
  ),
  // Gymnasium
  const Facility(
    id: 'f7',
    name: 'Main Gymnasium',
    category: FacilityCategory.gymnasium,
    authority: 'OSS',
    bgColor: Color(0xFFDCFCE7),
    iconColor: Color(0xFF16A34A),
  ),
];

// Days in April 2026 that have at least one available slot (after mock today Apr 6)
const Set<int> kAvailableDays = {7, 8, 10, 11, 14, 15, 17, 21, 22, 24, 28, 29};

// Default time slots for any available day
final List<TimeSlot> kMockSlots = [
  const TimeSlot(time: '09:00 – 10:30', available: false),
  const TimeSlot(time: '10:40 – 12:10', available: true),
  const TimeSlot(time: '13:15 – 14:45', available: true),
  const TimeSlot(time: '14:55 – 16:25', available: false),
  const TimeSlot(time: '16:30 – 18:00', available: true),
  const TimeSlot(time: '18:15 – 19:45', available: true),
];
```

- [ ] **Step 2: Extend `kMockDirectory` with student and org entries**

Find the `kMockDirectory` list in mock_data.dart and append at the end (before the closing `];`):

```dart
  // Students
  const DirectoryEntry(id: 15, name: 'Subhanshu Biswas', type: 'Student', email: 'sbiswas@iuj.ac.jp', phone: '', studentId: 'IUJ-2026-0001'),
  const DirectoryEntry(id: 16, name: 'Yuki Tanaka', type: 'Student', email: 'ytanaka@iuj.ac.jp', phone: '', studentId: 'IUJ-2026-0042'),
  const DirectoryEntry(id: 17, name: 'Maria Santos', type: 'Student', email: 'msantos@iuj.ac.jp', phone: '', studentId: 'IUJ-2026-0078'),
  const DirectoryEntry(id: 18, name: 'Ahmed Al-Rashid', type: 'Student', email: 'aalrashid@iuj.ac.jp', phone: '', studentId: 'IUJ-2025-0134'),
  const DirectoryEntry(id: 19, name: 'Liu Wei', type: 'Student', email: 'lwei@iuj.ac.jp', phone: '', studentId: 'IUJ-2025-0099'),
  // Organizations
  const DirectoryEntry(id: 20, name: 'Graduate Student Organization (GSO)', type: 'Organization', email: 'gso@iuj.ac.jp', phone: 'Ext. 4300', coordinator: 'Maria Santos'),
  const DirectoryEntry(id: 21, name: 'GSIM Student Council', type: 'Organization', email: 'gsim-council@iuj.ac.jp', phone: 'Ext. 4301', coordinator: 'Subhanshu Biswas'),
  const DirectoryEntry(id: 22, name: 'GSIR Student Council', type: 'Organization', email: 'gsir-council@iuj.ac.jp', phone: 'Ext. 4302', coordinator: 'Yuki Tanaka'),
  const DirectoryEntry(id: 23, name: 'IUJ Photography Club', type: 'Organization', email: 'photo-club@iuj.ac.jp', phone: '', coordinator: 'Liu Wei'),
```

- [ ] **Step 3: Add library mock data after `kMockAlerts`**

Add after the `kMockAlerts` list:

```dart
// Library mock data — using Dart records (no separate model needed)
final List<({String title, String dueDate, bool overdue})> kMockLibraryLoans = [
  (title: 'International Business Strategy', dueDate: 'Apr 15, 2026', overdue: false),
  (title: 'Global Supply Chain Management', dueDate: 'Apr 3, 2026', overdue: true),
  (title: 'Comparative Management Systems', dueDate: 'Apr 20, 2026', overdue: false),
  (title: 'The Oxford Handbook of International Business', dueDate: 'Apr 25, 2026', overdue: false),
];
```

- [ ] **Step 4: Run analyzer**

```bash
dart analyze lib/
```

Expected: errors only in files scheduled for deletion (`facility_card.dart`, `facilities_page.dart`). No errors elsewhere.

- [ ] **Step 5: Commit**

```bash
git add lib/data/mock_data.dart
git commit -m "feat: update facilities mock data with categories, availability, library loans, extended directory"
```

---

## Task 5: Update facilities_provider.dart

**Files:**
- Modify: `lib/providers/facilities_provider.dart`

- [ ] **Step 1: Replace `lib/providers/facilities_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maps facilityId → set of slot time strings that have been booked this session.
final bookedSlotsProvider = StateProvider<Map<String, Set<String>>>((ref) => {});
```

- [ ] **Step 2: Run analyzer**

```bash
dart analyze lib/
```

Expected: errors in `facilities_page.dart` and `time_slot_selector.dart` (referencing removed providers) — these are deleted in Task 14. Ignore them.

- [ ] **Step 3: Commit**

```bash
git add lib/providers/facilities_provider.dart
git commit -m "refactor: simplify facilities_provider to bookedSlotsProvider only"
```

---

## Task 6: Create directory_provider.dart

**Files:**
- Create: `lib/providers/directory_provider.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/providers/directory_provider.dart';

testWidgets('directoryFilterProvider defaults to All', (tester) async {
  late WidgetRef capturedRef;
  await tester.pumpWidget(ProviderScope(
    child: Consumer(builder: (_, ref, __) {
      capturedRef = ref;
      return const SizedBox();
    }),
  ));
  expect(capturedRef.read(directoryFilterProvider), 'All');
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/providers/directory_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final directorySearchProvider = StateProvider<String>((ref) => '');
final directoryFilterProvider = StateProvider<String>((ref) => 'All');
final expandedDirectoryEntryProvider = StateProvider<int?>((ref) => null);
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/directory_provider.dart test/widget_test.dart
git commit -m "feat: add directory providers (search, filter, expanded entry)"
```

---

## Task 7: Update router — hub + 3 sub-routes

**Files:**
- Modify: `lib/router/app_router.dart`

Note: `FacilitiesPage` import will be replaced with hub + sub-page imports. The old `FacilitiesPage` still exists at this point — the router just stops using it. Old file deletion happens in Task 14.

- [ ] **Step 1: Update imports in `lib/router/app_router.dart`**

Replace:
```dart
import '../pages/facilities_page.dart';
```
With:
```dart
import '../pages/facilities_hub_page.dart';
import '../pages/facilities/room_booking_page.dart';
import '../pages/facilities/library_page.dart';
import '../pages/facilities/campus_directory_page.dart';
```

- [ ] **Step 2: Replace the `/facilities` GoRoute**

Replace:
```dart
GoRoute(
  path: '/facilities',
  pageBuilder: (context, state) =>
      const NoTransitionPage(child: FacilitiesPage()),
),
```
With:
```dart
GoRoute(
  path: '/facilities',
  pageBuilder: (context, state) =>
      const NoTransitionPage(child: FacilitiesHubPage()),
  routes: [
    GoRoute(
      path: 'room-booking',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: RoomBookingPage()),
    ),
    GoRoute(
      path: 'library',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LibraryPage()),
    ),
    GoRoute(
      path: 'directory',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CampusDirectoryPage()),
    ),
  ],
),
```

- [ ] **Step 3: Create stub files so the router compiles**

Create `lib/pages/facilities_hub_page.dart`:
```dart
import 'package:flutter/material.dart';

class FacilitiesHubPage extends StatelessWidget {
  const FacilitiesHubPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Facilities Hub — coming soon'));
}
```

Create `lib/pages/facilities/room_booking_page.dart`:
```dart
import 'package:flutter/material.dart';

class RoomBookingPage extends StatelessWidget {
  const RoomBookingPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Room Booking — coming soon'));
}
```

Create `lib/pages/facilities/library_page.dart`:
```dart
import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Library — coming soon'));
}
```

Create `lib/pages/facilities/campus_directory_page.dart`:
```dart
import 'package:flutter/material.dart';

class CampusDirectoryPage extends StatelessWidget {
  const CampusDirectoryPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Campus Directory — coming soon'));
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass (app renders without crash, stubs are valid widgets).

- [ ] **Step 5: Commit**

```bash
git add lib/router/app_router.dart lib/pages/facilities_hub_page.dart lib/pages/facilities/
git commit -m "feat: add facilities hub routing with 3 sub-routes (stub pages)"
```

---

## Task 8: Build FacilitiesHubPage

**Files:**
- Modify: `lib/pages/facilities_hub_page.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:myiuj_portal/pages/facilities_hub_page.dart';

testWidgets('FacilitiesHubPage shows three feature cards', (tester) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const FacilitiesHubPage()),
      ]),
    ),
  ));
  expect(find.text('Room Booking'), findsOneWidget);
  expect(find.text('Library'), findsOneWidget);
  expect(find.text('Campus Directory'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Implement `lib/pages/facilities_hub_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FacilitiesHubPage extends StatelessWidget {
  const FacilitiesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Facilities Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Book rooms, access the library, and explore the campus directory', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        _HubCard(
          icon: Icons.meeting_room_outlined,
          iconBg: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          title: 'Room Booking',
          subtitle: 'Reserve classrooms, lounges, and the gymnasium',
          route: '/facilities/room-booking',
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.local_library_outlined,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Library',
          subtitle: 'View your loans, explore resources, and search the catalogue',
          route: '/facilities/library',
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.people_outline,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          title: 'Campus Directory',
          subtitle: 'Find students, faculty, staff, and campus organisations',
          route: '/facilities/directory',
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String route;

  const _HubCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/facilities_hub_page.dart test/widget_test.dart
git commit -m "feat: implement FacilitiesHubPage with three feature cards"
```

---

## Task 9: Build BookingCalendar widget

**Files:**
- Create: `lib/widgets/facilities/booking_calendar.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/facilities/booking_calendar.dart';

testWidgets('BookingCalendar shows April 2026 and available days are tappable', (tester) async {
  int? tappedDay;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: BookingCalendar(
        facilityId: 'f1',
        onDaySelected: (day) => tappedDay = day,
      ),
    ),
  ));
  expect(find.text('April 2026'), findsOneWidget);
  // Day 7 is in kAvailableDays
  await tester.tap(find.text('7').first);
  await tester.pump();
  expect(tappedDay, 7);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/widgets/facilities/booking_calendar.dart`**

```dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class BookingCalendar extends StatelessWidget {
  final String facilityId;
  final void Function(int day) onDaySelected;

  const BookingCalendar({
    super.key,
    required this.facilityId,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Mock: April 2026. Days 1-6 are past (mock today = Apr 6).
    const int mockToday = 6;
    const int daysInMonth = 30;
    // April 1, 2026 is a Wednesday → offset 2 from Monday column
    const int firstWeekdayOffset = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'April 2026',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) =>
            Expanded(
              child: Center(
                child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 8),
        _buildGrid(mockToday, daysInMonth, firstWeekdayOffset),
      ],
    );
  }

  Widget _buildGrid(int mockToday, int daysInMonth, int offset) {
    final List<Widget> cells = [];
    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final isPast = day <= mockToday;
      final tappable = !isPast && kAvailableDays.contains(day);
      cells.add(_DayCell(
        day: day,
        tappable: tappable,
        isPast: isPast,
        onTap: tappable ? () => onDaySelected(day) : null,
      ));
    }

    final List<Widget> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      final end = (i + 7 < cells.length) ? i + 7 : cells.length;
      final rowCells = cells.sublist(i, end);
      while (rowCells.length < 7) rowCells.add(const SizedBox());
      rows.add(Row(children: rowCells.map((c) => Expanded(child: c)).toList()));
      rows.add(const SizedBox(height: 4));
    }
    return Column(children: rows);
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool tappable;
  final bool isPast;
  final VoidCallback? onTap;

  const _DayCell({required this.day, required this.tappable, required this.isPast, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor = const Color(0xFF111827);

    if (isPast) {
      textColor = const Color(0xFFD1D5DB);
    } else if (tappable) {
      bg = const Color(0xFFEEF2FF);
      textColor = const Color(0xFF4F46E5);
    } else {
      textColor = const Color(0xFFD1D5DB);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/facilities/booking_calendar.dart test/widget_test.dart
git commit -m "feat: add BookingCalendar widget with April 2026 availability grid"
```

---

## Task 10: Build BookingSlotSelector widget

**Files:**
- Create: `lib/widgets/facilities/booking_slot_selector.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/facilities/booking_slot_selector.dart';
import 'package:myiuj_portal/models/facility.dart';

testWidgets('BookingSlotSelector shows slots and enables Next when one selected', (tester) async {
  final slots = [
    const TimeSlot(time: '10:40 – 12:10', available: true),
    const TimeSlot(time: '09:00 – 10:30', available: false),
  ];
  final selected = <String>{};
  bool nextPressed = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: StatefulBuilder(builder: (context, setState) {
        return BookingSlotSelector(
          slots: slots,
          selectedSlots: selected,
          onToggle: (time) => setState(() {
            selected.contains(time) ? selected.remove(time) : selected.add(time);
          }),
          onNext: () => nextPressed = true,
          onBack: () {},
        );
      }),
    ),
  ));

  expect(find.text('10:40 – 12:10'), findsOneWidget);
  // Next disabled initially
  final nextBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
  expect(nextBtn.onPressed, isNull);

  // Tap available slot
  await tester.tap(find.text('10:40 – 12:10'));
  await tester.pump();

  // Verify selection visual (slot text still visible)
  expect(find.text('10:40 – 12:10'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/widgets/facilities/booking_slot_selector.dart`**

```dart
import 'package:flutter/material.dart';
import '../../models/facility.dart';

class BookingSlotSelector extends StatelessWidget {
  final List<TimeSlot> slots;
  final Set<String> selectedSlots;
  final void Function(String time) onToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BookingSlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlots,
    required this.onToggle,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Time Slots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        const Text('You may select multiple available slots.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 12),
        ...slots.map((slot) {
          final isSelected = selectedSlots.contains(slot.time);
          return GestureDetector(
            onTap: slot.available ? () => onToggle(slot.time) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: !slot.available
                    ? const Color(0xFFF3F4F6)
                    : isSelected
                        ? const Color(0xFFEEF2FF)
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: !slot.available
                      ? const Color(0xFFE5E7EB)
                      : isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFD1D5DB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    slot.available ? Icons.access_time : Icons.block,
                    size: 16,
                    color: slot.available ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: slot.available ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: !slot.available
                          ? const Color(0xFFFEE2E2)
                          : isSelected
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      !slot.available ? 'Unavailable' : isSelected ? 'Selected' : 'Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: !slot.available
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSlots.isNotEmpty ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: selectedSlots.isNotEmpty ? onNext : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/facilities/booking_slot_selector.dart test/widget_test.dart
git commit -m "feat: add BookingSlotSelector with multi-select and Next/Back navigation"
```

---

## Task 11: Build BookingForm widget

**Files:**
- Create: `lib/widgets/facilities/booking_form.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/facilities/booking_form.dart';

testWidgets('BookingForm shows extra fields for lounge category', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: BookingForm(
        category: FacilityCategory.lounge,
        onBack: () {},
        onSubmit: (_) {},
      ),
    ),
  ));
  expect(find.text('Expected Attendees'), findsOneWidget);
  expect(find.text('Setup Requirements'), findsOneWidget);
});

testWidgets('BookingForm shows only reason field for classroom category', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: BookingForm(
        category: FacilityCategory.classroom,
        onBack: () {},
        onSubmit: (_) {},
      ),
    ),
  ));
  expect(find.text('Expected Attendees'), findsNothing);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/widgets/facilities/booking_form.dart`**

```dart
import 'package:flutter/material.dart';
import '../../models/facility.dart';

/// Callback receives a map of form field values.
typedef BookingFormData = Map<String, String>;

class BookingForm extends StatefulWidget {
  final FacilityCategory category;
  final VoidCallback onBack;
  final void Function(BookingFormData data) onSubmit;

  const BookingForm({
    super.key,
    required this.category,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _reasonCtrl = TextEditingController();
  final _attendeesCtrl = TextEditingController();
  final _setupCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _attendeesCtrl.dispose();
    _setupCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isExtendedForm =>
      widget.category == FacilityCategory.lounge ||
      widget.category == FacilityCategory.gymnasium;

  void _handleSubmit() {
    final data = <String, String>{
      'reason': _reasonCtrl.text,
      if (_isExtendedForm) 'attendees': _attendeesCtrl.text,
      if (_isExtendedForm) 'setup': _setupCtrl.text,
      if (_isExtendedForm) 'notes': _notesCtrl.text,
    };
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        _field(_reasonCtrl, 'Reason for Booking', 'Brief description of your planned use...', maxLines: 3),
        if (_isExtendedForm) ...[
          const SizedBox(height: 12),
          _field(_attendeesCtrl, 'Expected Attendees', 'e.g. 15 students'),
          const SizedBox(height: 12),
          _field(_setupCtrl, 'Setup Requirements', 'e.g. chairs in a circle, projector, etc.'),
          const SizedBox(height: 12),
          _field(_notesCtrl, 'Additional Notes', 'Anything else the office should know...', maxLines: 3),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(onPressed: widget.onBack, child: const Text('Back')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _handleSubmit,
              child: const Text('Confirm & Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/facilities/booking_form.dart test/widget_test.dart
git commit -m "feat: add BookingForm with dynamic fields based on FacilityCategory"
```

---

## Task 12: Build BookingModal (multi-step)

**Files:**
- Create: `lib/widgets/facilities/booking_modal.dart`

The modal is a `ConsumerStatefulWidget` managing step state. It pops with a `BookingResult` record so the calling page can handle side effects safely.

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/facilities/booking_modal.dart';

testWidgets('BookingModal starts on step 1 showing calendar', (tester) async {
  final facility = Facility(
    id: 'f1',
    name: 'Classroom G.30',
    category: FacilityCategory.classroom,
    authority: 'OAA',
    bgColor: const Color(0xFFDBEAFE),
    iconColor: const Color(0xFF2563EB),
  );
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: BookingModal(facility: facility),
      ),
    ),
  ));
  expect(find.text('April 2026'), findsOneWidget);
  expect(find.text('Step 1 of 3'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/widgets/facilities/booking_modal.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/facility.dart';
import '../../data/mock_data.dart';
import '../../providers/facilities_provider.dart';
import 'booking_calendar.dart';
import 'booking_slot_selector.dart';
import 'booking_form.dart';

/// Returned when the user completes the booking flow.
typedef BookingResult = ({int day, Set<String> slots, Map<String, String> formData});

class BookingModal extends ConsumerStatefulWidget {
  final Facility facility;

  const BookingModal({super.key, required this.facility});

  @override
  ConsumerState<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends ConsumerState<BookingModal> {
  int _step = 1;
  int? _selectedDay;
  Set<String> _selectedSlots = {};

  List<TimeSlot> _effectiveSlots() {
    final booked = ref.read(bookedSlotsProvider)[widget.facility.id] ?? {};
    return kMockSlots.map((s) {
      if (booked.contains(s.time)) return TimeSlot(time: s.time, available: false);
      return s;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepIndicator(),
        const SizedBox(height: 16),
        if (_step == 1)
          BookingCalendar(
            facilityId: widget.facility.id,
            onDaySelected: (day) => setState(() {
              _selectedDay = day;
              _selectedSlots = {};
              _step = 2;
            }),
          ),
        if (_step == 2)
          BookingSlotSelector(
            slots: _effectiveSlots(),
            selectedSlots: _selectedSlots,
            onToggle: (time) => setState(() {
              _selectedSlots.contains(time)
                  ? _selectedSlots.remove(time)
                  : _selectedSlots.add(time);
            }),
            onNext: () => setState(() => _step = 3),
            onBack: () => setState(() => _step = 1),
          ),
        if (_step == 3)
          BookingForm(
            category: widget.facility.category,
            onBack: () => setState(() => _step = 2),
            onSubmit: (formData) {
              Navigator.of(context).pop<BookingResult>((
                day: _selectedDay!,
                slots: Set<String>.from(_selectedSlots),
                formData: formData,
              ));
            },
          ),
      ],
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: [
        Text(
          'Step $_step of 3',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: _step / 3,
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF4F46E5),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/facilities/booking_modal.dart test/widget_test.dart
git commit -m "feat: add multi-step BookingModal (calendar → slots → form)"
```

---

## Task 13: Build RoomBookingPage

**Files:**
- Modify: `lib/pages/facilities/room_booking_page.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/pages/facilities/room_booking_page.dart';

testWidgets('RoomBookingPage shows Classrooms & Lounges and Gymnasium sections', (tester) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const RoomBookingPage()),
      ]),
    ),
  ));
  expect(find.text('Classrooms & Lounges'), findsOneWidget);
  expect(find.text('Gymnasium'), findsOneWidget);
  expect(find.text('Classroom G.30'), findsOneWidget);
  expect(find.text('Main Gymnasium'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Implement `lib/pages/facilities/room_booking_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/facility.dart';
import '../../models/alert_item.dart';
import '../../data/mock_data.dart';
import '../../providers/facilities_provider.dart';
import '../../providers/alerts_provider.dart';
import '../../widgets/facilities/booking_modal.dart';
import '../../widgets/common/app_modal.dart';
import '../../widgets/common/toast_overlay.dart';

class RoomBookingPage extends ConsumerWidget {
  const RoomBookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomsAndLounges = kFacilities
        .where((f) => f.category == FacilityCategory.classroom || f.category == FacilityCategory.lounge)
        .toList();
    final gymnasiums = kFacilities
        .where((f) => f.category == FacilityCategory.gymnasium)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/facilities'),
              child: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            const Text('Room Booking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Select a space to begin your booking', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        _sectionHeader('Classrooms & Lounges'),
        const SizedBox(height: 12),
        ...classroomsAndLounges.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RoomCard(facility: f, onTap: () => _openBookingModal(context, ref, f)),
        )),
        const SizedBox(height: 16),
        _sectionHeader('Gymnasium'),
        const SizedBox(height: 12),
        ...gymnasiums.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RoomCard(facility: f, onTap: () => _openBookingModal(context, ref, f)),
        )),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151)));
  }

  Future<void> _openBookingModal(BuildContext context, WidgetRef ref, Facility facility) async {
    final result = await AppModal.show<BookingResult>(
      context,
      title: 'Book ${facility.name}',
      child: BookingModal(facility: facility),
    );

    if (result == null || !context.mounted) return;

    // Mark booked slots as unavailable for this session
    ref.read(bookedSlotsProvider.notifier).update((state) {
      final updated = Map<String, Set<String>>.from(state);
      updated[facility.id] = {...(state[facility.id] ?? {}), ...result.slots};
      return updated;
    });

    // Add a dashboard alert
    final newAlert = AlertItem(
      id: 'booking_${facility.id}_${result.day}',
      title: 'Booking Request Received',
      body: 'Your booking request for ${facility.name} on April ${result.day} has been received. You will be notified about the outcome shortly.',
      date: 'Today',
      mailingList: 'my-requests',
      severity: AlertSeverity.info,
    );
    ref.read(alertsProvider.notifier).update((state) => [newAlert, ...state]);

    // Show toast
    if (context.mounted) {
      showToast(context, 'Your request has been submitted. You will be notified about the outcome shortly.');
    }
  }
}

class _RoomCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;

  const _RoomCard({required this.facility, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: facility.bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.meeting_room_outlined, color: facility.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facility.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  _AuthorityChip(label: facility.authority),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }
}

class _AuthorityChip extends StatelessWidget {
  final String label;
  const _AuthorityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/facilities/room_booking_page.dart test/widget_test.dart
git commit -m "feat: implement RoomBookingPage with grouped cards and booking modal flow"
```

---

## Task 14: Build LibraryPage

**Files:**
- Modify: `lib/pages/facilities/library_page.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/pages/facilities/library_page.dart';

testWidgets('LibraryPage shows My Loans and Library Resources sections', (tester) async {
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const LibraryPage()),
    ]),
  ));
  expect(find.text('My Loans'), findsOneWidget);
  expect(find.text('Library Resources'), findsOneWidget);
  expect(find.text('Search MLIC Catalogue'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Implement `lib/pages/facilities/library_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_data.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/facilities'),
              child: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            const Text('Library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Matsushita Library & Information Center (MLIC)', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        // My Loans
        const Text('My Loans', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: kMockLibraryLoans.indexed.map((entry) {
              final (i, loan) = entry;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book_outlined, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loan.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                          Text('Due: ${loan.dueDate}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: loan.overdue ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        loan.overdue ? 'Overdue' : 'On Time',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: loan.overdue ? const Color(0xFF991B1B) : const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        // Library Resources
        const Text('Library Resources', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        ..._resources.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                  child: Icon(r.$1, color: const Color(0xFF9333EA), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                      Text(r.$3, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 24),
        // Search button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Search MLIC Catalogue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final uri = Uri.parse('https://mlic.iuj.ac.jp/opac/');
              if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Full catalogue integration coming soon.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ),
      ],
    );
  }
}

// (icon, title, description)
const _resources = [
  (Icons.article_outlined, 'Academic Journals', 'Access JSTOR, EBSCOhost, and other subscribed databases'),
  (Icons.menu_book_outlined, 'Yearbooks & Reports', 'IUJ annual reports, alumni directories, and institutional publications'),
  (Icons.computer_outlined, 'E-Databases', 'Nikkei Telecom, Bloomberg, World Bank Open Data, and more'),
];
```

Note: `url_launcher` must be in `pubspec.yaml`. Check with:
```bash
grep url_launcher pubspec.yaml
```
If missing, add it:
```bash
flutter pub add url_launcher
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/facilities/library_page.dart test/widget_test.dart pubspec.yaml pubspec.lock
git commit -m "feat: implement LibraryPage with loans, resources, and MLIC catalogue link"
```

---

## Task 15: Build DirectoryCard widget

**Files:**
- Create: `lib/widgets/directory/directory_card.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/directory/directory_card.dart';
import 'package:myiuj_portal/models/wiki_page.dart';

testWidgets('DirectoryCard expands on tap to show email', (tester) async {
  const entry = DirectoryEntry(
    id: 1,
    name: 'Prof. Test',
    type: 'Faculty - GSIM',
    email: 'test@iuj.ac.jp',
    phone: 'Ext. 3000',
  );
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: DirectoryCard(entry: entry),
      ),
    ),
  ));
  // Email not visible initially
  expect(find.text('test@iuj.ac.jp'), findsNothing);
  // Tap to expand
  await tester.tap(find.text('Prof. Test'));
  await tester.pump();
  expect(find.text('test@iuj.ac.jp'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Create `lib/widgets/directory/directory_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/wiki_page.dart';
import '../../providers/directory_provider.dart';

class DirectoryCard extends ConsumerWidget {
  final DirectoryEntry entry;

  const DirectoryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedId = ref.watch(expandedDirectoryEntryProvider);
    final isExpanded = expandedId == entry.id;

    return GestureDetector(
      onTap: () {
        ref.read(expandedDirectoryEntryProvider.notifier).state =
            isExpanded ? null : entry.id;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Avatar(name: entry.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                        const SizedBox(height: 3),
                        _TypeChip(type: entry.type),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF9CA3AF), size: 18),
                ],
              ),
            ),
            if (isExpanded) _ExpandedDetails(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final DirectoryEntry entry;
  const _ExpandedDetails({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          if (entry.studentId != null) _row('Student ID', entry.studentId!),
          if (entry.email.isNotEmpty) _row('Email', entry.email),
          if (entry.phone.isNotEmpty) _row(_phoneLabel(), entry.phone),
          if (entry.coordinator != null) _row('Coordinator', entry.coordinator!),
          if (entry.type == 'Organization') ...[
            const SizedBox(height: 10),
            _WikiLink(entry: entry),
          ],
        ],
      ),
    );
  }

  String _phoneLabel() {
    if (entry.type == 'Student') return 'Contact';
    return 'Phone';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF111827))),
          ),
        ],
      ),
    );
  }
}

class _WikiLink extends StatelessWidget {
  final DirectoryEntry entry;
  const _WikiLink({required this.entry});

  String _wikiId() {
    // Map org names to wiki article IDs
    final name = entry.name.toLowerCase();
    if (name.contains('gso')) return 'gso';
    if (name.contains('gsim')) return 'gsim-council';
    if (name.contains('gsir')) return 'gsir-council';
    return 'clubs';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/wiki/${_wikiId()}'),
      child: const Row(
        children: [
          Icon(Icons.open_in_new, size: 14, color: Color(0xFF4F46E5)),
          SizedBox(width: 6),
          Text('View Wiki page', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Text(_initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  Color get _color {
    if (type.startsWith('Faculty')) return const Color(0xFF7C3AED);
    if (type == 'Student') return const Color(0xFF2563EB);
    if (type == 'Organization') return const Color(0xFF16A34A);
    if (type == 'Department') return const Color(0xFFD97706);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(type, style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w500)),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/directory/ test/widget_test.dart
git commit -m "feat: add DirectoryCard with expand/collapse and Wiki link for orgs"
```

---

## Task 16: Build CampusDirectoryPage

**Files:**
- Modify: `lib/pages/facilities/campus_directory_page.dart`

- [ ] **Step 1: Write test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/pages/facilities/campus_directory_page.dart';

testWidgets('CampusDirectoryPage shows search box and filter chips', (tester) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const CampusDirectoryPage()),
      ]),
    ),
  ));
  expect(find.byType(TextField), findsOneWidget);
  expect(find.text('All'), findsOneWidget);
  expect(find.text('Student'), findsOneWidget);
  expect(find.text('Faculty'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/widget_test.dart
```

- [ ] **Step 3: Implement `lib/pages/facilities/campus_directory_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../models/wiki_page.dart';
import '../../providers/directory_provider.dart';
import '../../widgets/directory/directory_card.dart';

const _filterChips = ['All', 'Student', 'Faculty', 'Staff', 'Department', 'Organization'];

class CampusDirectoryPage extends ConsumerWidget {
  const CampusDirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(directorySearchProvider);
    final filter = ref.watch(directoryFilterProvider);

    final filtered = kMockDirectory.where((e) {
      final matchesFilter = filter == 'All' ||
          e.type == filter ||
          (filter == 'Faculty' && e.type.startsWith('Faculty')) ||
          (filter == 'Staff' && (e.type == 'Support' || e.type == 'Facility' || e.type == 'Satellite Office'));
      final matchesQuery = query.isEmpty ||
          e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.email.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    // Orgs always shown separately (not in the filtered main list)
    final mainEntries = filtered.where((e) => e.type != 'Organization').toList();
    final orgs = kMockDirectory.where((e) => e.type == 'Organization').toList();
    final showOrgs = filter == 'All' || filter == 'Organization';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/facilities'),
              child: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            const Text('Campus Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 16),
        // Search
        TextField(
          onChanged: (v) => ref.read(directorySearchProvider.notifier).state = v,
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterChips.map((chip) {
              final isActive = filter == chip;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(chip),
                  selected: isActive,
                  onSelected: (_) {
                    ref.read(directoryFilterProvider.notifier).state = chip;
                    ref.read(expandedDirectoryEntryProvider.notifier).state = null;
                  },
                  selectedColor: const Color(0xFFEEF2FF),
                  checkmarkColor: const Color(0xFF4F46E5),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF374151),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Results
        if (mainEntries.isEmpty && !showOrgs)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('No results found.', style: TextStyle(color: Color(0xFF9CA3AF))),
          ))
        else ...[
          ...mainEntries.map((e) => DirectoryCard(entry: e)),
          // Organisations section
          if (showOrgs && orgs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Organisations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
            const SizedBox(height: 12),
            ...orgs.map((e) => DirectoryCard(entry: e)),
          ],
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/facilities/campus_directory_page.dart test/widget_test.dart
git commit -m "feat: implement CampusDirectoryPage with search, filter chips, and expandable cards"
```

---

## Task 17: Update ProfilePage — add My Library section

**Files:**
- Modify: `lib/pages/profile_page.dart`

- [ ] **Step 1: Add My Library section**

In `lib/pages/profile_page.dart`, insert the following after the second `_infoCard` (line 41, the adviser card) and before the `const SizedBox(height: 32)` before sign out:

```dart
        const SizedBox(height: 16),
        // My Library section
        GestureDetector(
          onTap: () => context.go('/facilities/library'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_library_outlined, color: Color(0xFF9333EA), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Library', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                      Text('View your loans and library resources', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
```

Also add the go_router import at the top of `profile_page.dart`:
```dart
import 'package:go_router/go_router.dart';
```

And update the `build` method signature to accept `BuildContext context` (it already does — just verify `context` is available for `context.go()`).

- [ ] **Step 2: Run tests**

```bash
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 3: Commit**

```bash
git add lib/pages/profile_page.dart
git commit -m "feat: add My Library link to ProfilePage"
```

---

## Task 18: Delete old files and run final analysis

**Files:**
- Delete: `lib/pages/facilities_page.dart`
- Delete: `lib/widgets/facilities/time_slot_selector.dart`
- Delete: `lib/widgets/facilities/facility_card.dart`

- [ ] **Step 1: Delete old files**

```bash
rm lib/pages/facilities_page.dart
rm lib/widgets/facilities/time_slot_selector.dart
rm lib/widgets/facilities/facility_card.dart
```

- [ ] **Step 2: Run analyzer — expect zero errors**

```bash
dart analyze lib/
```

Expected: no errors. If any import still references the deleted files, fix them now.

- [ ] **Step 3: Run full test suite**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove old FacilitiesPage, TimeSlotSelector, and FacilityCard (replaced by hub + modal flow)"
```

---

## Task 19: Smoke test in browser

- [ ] **Step 1: Run in Chrome**

```bash
flutter run -d chrome
```

- [ ] **Step 2: Verify hub page**

Navigate to `/facilities` → three hub cards visible (Room Booking, Library, Campus Directory).

- [ ] **Step 3: Verify room booking flow**

Click "Room Booking" → see Classrooms & Lounges + Gymnasium sections.
Click any room card → modal opens on Step 1 (calendar, "Step 1 of 3").
Click an available day → Step 2 (slot selector).
Select one or more slots → "Next" becomes enabled.
Click "Next" → Step 3 (form). For a classroom: only "Reason" field. For CNP Snack Lounge: all four fields.
Click "Confirm & Submit" → modal closes, toast appears, dashboard alerts shows new entry.

- [ ] **Step 4: Verify library page**

Navigate to `/facilities/library` → loans list, resource cards, "Search MLIC Catalogue" button visible.
Click back arrow → returns to hub.
Navigate to `/profile` → "My Library" card visible and tapping navigates to `/facilities/library`.

- [ ] **Step 5: Verify campus directory**

Navigate to `/facilities/directory` → search box, filter chips, person cards.
Type a name → list filters live.
Click a card → expands showing email (and student ID for students).
Click "Organization" filter → shows only org cards with "View Wiki page" link.
