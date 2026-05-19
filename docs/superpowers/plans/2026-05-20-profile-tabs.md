# Profile Page Tab Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the static profile page tabs with a working three-tab layout (Personal Info / Academic / Financial), dissolve the AdminVault, and add a persistent Report Issues entry point in both the page and the top nav bar.

**Architecture:** `ProfilePage` converts from `ConsumerWidget` to `ConsumerStatefulWidget` with a `TabController` (+ `SingleTickerProviderStateMixin`) driving a `TabBar` and conditional content rendering — `TabBarView` is skipped because the page lives inside `AppShell`'s `SingleChildScrollView`, which cannot bound its height. `TopNav` gains a `_ReportIssueButton` widget (warning triangle icon) placed before `ProfileChip`.

**Tech Stack:** Flutter 3.41.4, flutter_riverpod ^2.6.1, `TabController`, `ExpansionTile`-style manual expand via `StatefulWidget`.

---

## File Map

| File | Change |
|------|--------|
| `lib/data/mock_data.dart` | Add `kFinancialStatements` list |
| `lib/widgets/layout/top_nav.dart` | Add `_ReportIssueButton` widget before `ProfileChip` |
| `lib/pages/profile_page.dart` | Full rewrite — tabs, content, persistent report button |
| `test/widget_test.dart` | Add tests for tabs and top nav icon |

---

## Task 1: Add mock financial statement data

**Files:**
- Modify: `lib/data/mock_data.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write the failing test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/data/mock_data.dart';

// inside main():
test('kFinancialStatements has 6 entries and none are empty', () {
  expect(kFinancialStatements.length, 6);
  for (final s in kFinancialStatements) {
    expect(s, isNotEmpty);
  }
});
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widget_test.dart
```

Expected: FAIL — `kFinancialStatements` not defined.

- [ ] **Step 3: Add the list to mock_data.dart**

At the bottom of `lib/data/mock_data.dart`, add:

```dart
const List<String> kFinancialStatements = [
  'November 2025 Statement',
  'December 2025 Statement',
  'January 2026 Statement',
  'February 2026 Statement',
  'March 2026 Statement',
  'April 2026 Statement',
];
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widget_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/mock_data.dart test/widget_test.dart
git commit -m "feat: add mock financial statements data"
```

---

## Task 2: Add Report Issues icon to TopNav

**Files:**
- Modify: `lib/widgets/layout/top_nav.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write the failing test**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/widgets/layout/top_nav.dart';

// inside main():
testWidgets('TopNav shows warning report icon', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: TopNav()),
      ),
    ),
  );
  expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widget_test.dart
```

Expected: FAIL — `Icons.warning_amber_rounded` not found.

- [ ] **Step 3: Add `_ReportIssueButton` to top_nav.dart**

Add these imports at the top of `lib/widgets/layout/top_nav.dart`:

```dart
import '../common/app_modal.dart';
import '../profile/issue_report_modal.dart';
```

In the `TopNav.build` `Row`, add `_ReportIssueButton()` and a `SizedBox` **before** `_AlertButton()`:

```dart
_ReportIssueButton(),
const SizedBox(width: 4),
_AlertButton(),
const SizedBox(width: 10),
const ProfileChip(),
```

Add the new widget class at the bottom of the file:

```dart
class _ReportIssueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Report an Issue',
      child: IconButton(
        onPressed: () => _showIssueReport(context),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.warning,
          size: 20,
        ),
      ),
    );
  }

  Future<void> _showIssueReport(BuildContext context) async {
    final submitted = await AppModal.show<bool>(
      context,
      title: 'Report an Issue',
      child: const IssueReportModal(),
    );
    if (!context.mounted || submitted != true) return;
    showToast(context, 'Report submitted.', type: ToastType.success);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widget_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/layout/top_nav.dart test/widget_test.dart
git commit -m "feat: add report issues icon to top nav"
```

---

## Task 3: Rewrite ProfilePage with functional tabs

**Files:**
- Modify: `lib/pages/profile_page.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write the failing tests**

Add to `test/widget_test.dart`:

```dart
import 'package:myiuj_portal/pages/profile_page.dart';

// inside main():
testWidgets('ProfilePage shows three tabs', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfilePage()),
        ),
      ),
    ),
  );
  expect(find.text('Personal Info'), findsOneWidget);
  expect(find.text('Academic'), findsOneWidget);
  expect(find.text('Financial'), findsOneWidget);
});

testWidgets('ProfilePage Financial tab shows statement list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfilePage()),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Financial'));
  await tester.pumpAndSettle();
  expect(find.text('April 2026 Statement'), findsOneWidget);
});

testWidgets('ProfilePage has persistent Report an Issue button', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfilePage()),
        ),
      ),
    ),
  );
  expect(find.text('Report an Issue'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/widget_test.dart
```

Expected: FAIL — ProfilePage doesn't have the new structure yet.

- [ ] **Step 3: Rewrite profile_page.dart**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_modal.dart';
import '../widgets/common/page_chrome.dart';
import '../widgets/common/toast_overlay.dart';
import '../widgets/profile/digital_id_card.dart';
import '../widgets/profile/issue_report_modal.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageGreeting(
          title: 'Profile',
          meta: [
            MetaText('Apoorv Terwadkar · GSIM MBA'),
            MetaDot(),
            MetaText('Spring 2026 · Valid', emphasis: true),
          ],
        ),
        const SizedBox(height: 18),
        const DigitalIdCard(),
        const SizedBox(height: 18),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.ruleSoft,
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Academic'),
            Tab(text: 'Financial'),
          ],
        ),
        const SizedBox(height: 18),
        _tabContent(),
        const SizedBox(height: 24),
        _reportIssuesButton(),
      ],
    );
  }

  Widget _tabContent() {
    return switch (_tabs.index) {
      0 => _personalInfoTab(),
      1 => _academicTab(),
      2 => _financialTab(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _personalInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoCard([
          ('Name', 'Apoorv Terwadkar'),
          ('Email', 'student@iuj.ac.jp'),
          ('Campus Address', 'Dorm A, Room 201'),
          ('Student ID', 'IUJ-2026-0001'),
        ]),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 160,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _academicTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoCard([
          ('Program', 'MBA — Graduate School of International Management'),
          ('Student ID', 'IUJ-2026-0001'),
          ('Year', '1st Year'),
          ('Status', 'Full-time'),
          ('Adviser', 'Prof. Remy Magnier-Watanabe'),
        ]),
        const SizedBox(height: 16),
        _libraryTile(),
        const SizedBox(height: 16),
        _changelogCard(),
      ],
    );
  }

  Widget _libraryTile() {
    return GestureDetector(
      onTap: () => context.go('/facilities/library'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ruleSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.local_library_outlined,
                color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Library',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Loans and library resources',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _changelogCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ruleSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Records Changelog',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          _ChangelogRow('Apr 24', 'Address record verified by OSS.'),
          _ChangelogRow('Apr 18', 'Library account synced.'),
          _ChangelogRow('Apr 10', 'Enrollment status confirmed.'),
          _ChangelogRow('Apr 02', 'Financial statement refreshed.'),
        ],
      ),
    );
  }

  Widget _financialTab() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ruleSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: kFinancialStatements.indexed.map((entry) {
          final (i, month) = entry;
          return _StatementRow(
            month: month,
            isFirst: i == 0,
            isLast: i == kFinancialStatements.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _reportIssuesButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.report_problem_outlined, size: 16),
      label: const Text('Report an Issue'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _showIssueReport(context),
    );
  }

  Future<void> _showIssueReport(BuildContext context) async {
    final submitted = await AppModal.show<bool>(
      context,
      title: 'Report an Issue',
      child: const IssueReportModal(),
    );
    if (!context.mounted || submitted != true) return;
    showToast(context, 'Report submitted.', type: ToastType.success);
  }

  Widget _infoCard(List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ruleSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: rows.indexed.map((entry) {
          final (i, row) = entry;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatementRow extends StatefulWidget {
  final String month;
  final bool isFirst;
  final bool isLast;

  const _StatementRow({
    required this.month,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<_StatementRow> createState() => _StatementRowState();
}

class _StatementRowState extends State<_StatementRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: widget.isFirst
            ? null
            : const Border(top: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(
          top: widget.isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: widget.isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(
              top: widget.isFirst ? const Radius.circular(12) : Radius.zero,
              bottom: !_expanded && widget.isLast
                  ? const Radius.circular(12)
                  : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    widget.month,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
                color: AppColors.bgSunken,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('Open'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => AppModal.show(
                      context,
                      title: widget.month,
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Document viewer coming soon.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download_outlined, size: 14),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.ruleSoft),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => AppModal.show(
                      context,
                      title: 'Download',
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Download coming soon.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChangelogRow extends StatelessWidget {
  final String date;
  final String text;

  const _ChangelogRow(this.date, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/widget_test.dart
```

Expected: PASS — all three new profile tests pass.

- [ ] **Step 5: Run analyze to catch any type errors**

```bash
flutter analyze lib/pages/profile_page.dart lib/widgets/layout/top_nav.dart
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/pages/profile_page.dart test/widget_test.dart
git commit -m "feat: rewrite profile page with functional tab layout"
```

---

## Self-Review

**Spec coverage:**
- ✅ Tabs renamed: Personal Info / Academic / Financial
- ✅ DigitalIdCard pinned above tabs
- ✅ TabBar with `TabController` (not `DefaultTabController` — skipped due to `SingleChildScrollView` height constraint; `TabController` is the direct equivalent)
- ✅ Personal Info: info card (Name, Email, Campus Address, Student ID) + sign out button
- ✅ Academic: Program/Year/Status/Adviser card + My Library tile + Records Changelog
- ✅ Financial: expandable monthly statement list with Open + Download buttons
- ✅ Report Issues: persistent button at page bottom
- ✅ Report Issues: warning triangle icon in TopNav
- ✅ `_AdminVault`, `_ProfileTabs`, `_ProfileTab`, `_VaultTile` deleted
- ✅ `_infoCard`, `_ChangelogRow`, `DigitalIdCard` retained
- ✅ Sign out button in Personal Info tab (bottom, right-aligned)
- ✅ Two-column layout removed; single-column per tab
- ✅ All colors via `AppColors` — no inline hex
- ✅ Mock data in `mock_data.dart`
- ✅ No new files created
