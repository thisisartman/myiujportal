import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/notification_prefs_provider.dart';
import '../providers/theme_provider.dart';
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
    _tabs = TabController(length: 5, vsync: this);
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
            MetaText('GSIM MBA · Spring 2026'),
            MetaDot(),
            MetaText('Valid', emphasis: true),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final leftColumn = _buildLeft();
            final rightColumn = _buildRight();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: leftColumn),
                  const SizedBox(width: 20),
                  Expanded(child: rightColumn),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftColumn,
                const SizedBox(height: 20),
                rightColumn,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DigitalIdCard(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.report_problem_outlined, size: 16),
          label: const Text('Report an Issue'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _showIssueReport(context),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, size: 16),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.ruleSoft),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _confirmSignOut(context),
        ),
      ],
    );
  }

  Widget _buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabs,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.ruleSoft,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Academic'),
            Tab(text: 'Financial'),
            Tab(text: 'My Library'),
            Tab(text: 'Settings'),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: KeyedSubtree(
            key: ValueKey(_tabs.index),
            child: _tabContent(),
          ),
        ),
      ],
    );
  }

  Widget _tabContent() {
    return switch (_tabs.index) {
      0 => _personalInfoTab(),
      1 => _academicTab(),
      2 => _financialTab(),
      3 => _myLibraryTab(),
      4 => _settingsTab(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _personalInfoTab() {
    return _infoCard([
      ('Name', 'Apoorv Terwadkar'),
      ('Email', 'student@iuj.ac.jp'),
      ('Campus Address', 'Dorm A, Room 201'),
      ('Student ID', 'IUJ-2026-0001'),
    ]);
  }

  Widget _academicTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _academicInfoCard(),
        const SizedBox(height: 16),
        _changelogCard(),
      ],
    );
  }

  Widget _academicInfoCard() {
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
        children: [
          _academicRow('Program', _programChips(), isFirst: true),
          _academicRow('Student ID', _plainValue('IUJ-2026-0001')),
          _academicRow('Year', _plainValue('1st Year')),
          _academicRow('Status', _plainValue('Full-time')),
          _academicRow('Mentor', _professorChip('Prof. Remy Magnier-Watanabe')),
          _academicRow('Research Supervisor', _professorChip('Prof. Maurice Thevenet')),
        ],
      ),
    );
  }

  Widget _academicRow(String label, Widget value, {bool isFirst = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _plainValue(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    );
  }

  Widget _programChips() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Graduate School of International Management (',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        _wikiChip('GSIM', '/wiki/02-Academics--gsim--about-gsim'),
        const Text(
          ') —',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        _wikiChip('MBA', '/wiki/02-Academics--gsim--program-mba'),
      ],
    );
  }

  Widget _professorChip(String name) {
    return _wikiChip(name, '/wiki/02-Academics--faculty--gsim-faculty');
  }

  Widget _wikiChip(String label, String route) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentBlue,
          ),
        ),
      ),
    );
  }

  Widget _myLibraryTab() {
    final active = kMockLibraryLoans;
    final history = kMockLibraryLoanHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active loans section
        Row(
          children: [
            const Text(
              'My Active Loans',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/facilities/library'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Go to My Library →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: active
                .map((loan) => _LibraryLoanRow(loan: loan, isHistory: false))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        // Loan history section
        const Text(
          'My Loan History',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: history
                .map((loan) => _LibraryLoanRow(loan: loan, isHistory: true))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _settingsTab() {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(dashboardSettingsProvider);
        final notifier = ref.read(dashboardSettingsProvider.notifier);
        final themeMode = ref.watch(themeProvider);
        final themeNotifier = ref.read(themeProvider.notifier);
        final prefs = ref.watch(notificationPrefsProvider);
        final prefsNotifier = ref.read(notificationPrefsProvider.notifier);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance ──────────────────────────────────────────────
            _sectionHeader('Appearance'),
            const SizedBox(height: 8),
            _settingGroup(
              'Theme',
              SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                  ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                ],
                selected: {themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (v) => themeNotifier.set(v.first),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // ── Notifications ────────────────────────────────────────────
            _sectionHeader('Notifications'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ruleSoft),
              ),
              child: Column(
                children: [
                  _toggleTile(
                    'Booking confirmations',
                    prefs.bookingAlerts,
                    () => prefsNotifier.update(
                      prefs.copyWith(bookingAlerts: !prefs.bookingAlerts),
                    ),
                    isFirst: true,
                  ),
                  _toggleTile(
                    'Announcements & news',
                    prefs.announcementAlerts,
                    () => prefsNotifier.update(
                      prefs.copyWith(announcementAlerts: !prefs.announcementAlerts),
                    ),
                  ),
                  _toggleTile(
                    'Calendar reminders',
                    prefs.calendarReminders,
                    () => prefsNotifier.update(
                      prefs.copyWith(calendarReminders: !prefs.calendarReminders),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // ── Calendar ─────────────────────────────────────────────────
            _sectionHeader('Calendar'),
            const SizedBox(height: 8),
            _settingGroup(
              'Default view',
              SegmentedButton<CalendarViewMode>(
                segments: const [
                  ButtonSegment(value: CalendarViewMode.month, label: Text('Month')),
                  ButtonSegment(value: CalendarViewMode.week, label: Text('Week')),
                  ButtonSegment(value: CalendarViewMode.agenda, label: Text('Agenda')),
                ],
                selected: {settings.defaultCalendarView},
                showSelectedIcon: false,
                onSelectionChanged: (v) =>
                    notifier.setDefaultCalendarView(v.first),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // ── Dashboard ────────────────────────────────────────────────
            _sectionHeader('Dashboard'),
            const SizedBox(height: 8),
            _settingGroup(
              'Dashboard columns',
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '1', label: Text('1')),
                  ButtonSegment(value: '2', label: Text('2')),
                  ButtonSegment(value: '3', label: Text('3')),
                ],
                selected: {settings.columnCount},
                showSelectedIcon: false,
                onSelectionChanged: (v) => notifier.setColumnCount(v.first),
              ),
            ),
            const SizedBox(height: 20),
            _settingGroup(
              'Quick link style',
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'icon-only', label: Text('Icon only')),
                  ButtonSegment(value: 'icon-label', label: Text('Icon + label')),
                  ButtonSegment(value: 'cards', label: Text('Cards')),
                ],
                selected: {settings.quickLinkStyle},
                showSelectedIcon: false,
                onSelectionChanged: (v) => notifier.setQuickLinkStyle(v.first),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Widget visibility',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ruleSoft),
              ),
              child: Column(
                children: [
                  _toggleTile('Up Next', settings.showUpNext, () => notifier.toggle('upNext'), isFirst: true),
                  _toggleTile('Timeline', settings.showTimeline, () => notifier.toggle('timeline')),
                  _toggleTile('Alerts', settings.showAlerts, () => notifier.toggle('alerts')),
                  _toggleTile('Quick Links', settings.showQuickLinks, () => notifier.toggle('quickLinks')),
                  _toggleTile('Digital ID', settings.showIdCard, () => notifier.toggle('idCard')),
                  _toggleTile('Library', settings.showLibrary, () => notifier.toggle('library')),
                  _toggleTile('Polls', settings.showPolls, () => notifier.toggle('polls')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingGroup(String label, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }

  Widget _toggleTile(String label, bool value, VoidCallback onTap, {bool isFirst = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        onChanged: (_) => onTap(),
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await AppModal.show<bool>(
      context,
      title: 'Sign out?',
      child: const Text(
        "You'll need to log in again to access your portal.",
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
    if (confirmed == true) ref.read(authProvider.notifier).logout();
  }

  Future<void> _showIssueReport(BuildContext context) async {
    final submitted = await AppModal.show<bool>(
      context,
      title: 'Report an Issue',
      child: const IssueReportModal(),
    );
    if (!context.mounted || submitted != true) return;
    showToast(
      context,
      'Report submitted. The relevant office has been notified.',
      type: ToastType.success,
    );
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
}

// ── Library loan row ──────────────────────────────────────────────────────────

class _LibraryLoanRow extends StatelessWidget {
  final ({String title, String author, String dueDate, bool overdue}) loan;
  final bool isHistory;

  const _LibraryLoanRow({required this.loan, required this.isHistory});

  @override
  Widget build(BuildContext context) {
    final Color accentColor;
    final String statusLabel;

    if (isHistory) {
      accentColor = loan.overdue ? AppColors.danger : AppColors.accentBlue;
      statusLabel = 'RETURNED';
    } else {
      final due = _parseDueDate(loan.dueDate);
      final days = due.difference(DateTime.now()).inDays;
      if (loan.overdue || days < 0) {
        accentColor = AppColors.danger;
        statusLabel = 'OVERDUE';
      } else if (days <= 5) {
        accentColor = AppColors.warning;
        statusLabel = 'DUE';
      } else {
        accentColor = AppColors.accentBlue;
        statusLabel = 'DUE';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgSunken,
              borderRadius: BorderRadius.circular(3),
              border: Border(left: BorderSide(color: accentColor, width: 4)),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loan.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              Text(
                loan.dueDate,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _parseDueDate(String dueDate) =>
      DateFormat('MMM d, yyyy').parse(dueDate);
}

// ── Financial statement row ───────────────────────────────────────────────────

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// ── Changelog row ─────────────────────────────────────────────────────────────

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
