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
          onPressed: () => ref.read(authProvider.notifier).logout(),
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
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Academic'),
            Tab(text: 'Financial'),
          ],
        ),
        const SizedBox(height: 18),
        _tabContent(),
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
            Icon(Icons.local_library_outlined, color: AppColors.primary, size: 20),
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
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
