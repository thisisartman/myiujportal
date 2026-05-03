import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_modal.dart';
import '../widgets/common/hover_card.dart';
import '../widgets/common/toast_overlay.dart';
import '../widgets/profile/digital_id_card.dart';
import '../widgets/profile/issue_report_modal.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final academicSection = Column(
      children: [
        _infoCard([
          ('Program', 'MBA — Graduate School of International Management'),
          ('Student ID', 'IUJ-2026-0001'),
          ('Year', '1st Year'),
          ('Status', 'Full-time'),
        ]),
        const SizedBox(height: 16),
        _infoCard([
          ('Adviser', 'Prof. Remy Magnier-Watanabe'),
          ('Campus Address', 'Dorm A, Room 201'),
        ]),
      ],
    );
    final adminVaultSection = _AdminVault(ref: ref);
    final signOutBtn = Align(
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
    );
    final leftCol = Column(
      children: [
        const DigitalIdCard(),
        const SizedBox(height: 16),
        academicSection,
      ],
    );
    final rightCol = Column(
      children: [adminVaultSection, const SizedBox(height: 24), signOutBtn],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCol),
              const SizedBox(width: 16),
              Expanded(child: rightCol),
            ],
          )
        else
          Column(children: [leftCol, const SizedBox(height: 16), rightCol]),
      ],
    );
  }

  Widget _infoCard(List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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

class _AdminVault extends StatelessWidget {
  final WidgetRef ref;

  const _AdminVault({required this.ref});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _VaultTile(
        icon: Icons.receipt_long_outlined,
        title: 'Financial Statement',
        subtitle: 'Tuition and payment records',
        onTap: () => AppModal.show(
          context,
          title: 'Financial Statement',
          child: const Text('Download placeholder'),
        ),
      ),
      _VaultTile(
        icon: Icons.local_library_outlined,
        title: 'My Library',
        subtitle: 'Loans and library resources',
        onTap: () => context.go('/facilities/library'),
      ),
      _VaultTile(
        icon: Icons.history_outlined,
        title: 'Records Changelog',
        subtitle: 'Recent admin updates',
        onTap: () => AppModal.show(
          context,
          title: 'Records Changelog',
          child: SizedBox(
            height: 220,
            child: ListView(
              children: const [
                _ChangelogRow('Apr 24', 'Address record verified by OSS.'),
                _ChangelogRow('Apr 18', 'Library account synced.'),
                _ChangelogRow('Apr 10', 'Enrollment status confirmed.'),
                _ChangelogRow('Apr 02', 'Financial statement refreshed.'),
              ],
            ),
          ),
        ),
      ),
      _VaultTile(
        icon: Icons.report_problem_outlined,
        title: 'Report Issues',
        subtitle: 'Facilities and campus support',
        onTap: () => _showIssueReport(context),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Vault',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: tiles,
          ),
        ],
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

class _VaultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VaultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
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
