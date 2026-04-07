import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text('S', style: TextStyle(color: AppColors.surface, fontSize: 32, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              const Text('Student', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Text('student@iuj.ac.jp', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 32),
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
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.go('/facilities/library'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_library_outlined, color: Color(0xFF9333EA), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Library', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('View your loans and library resources', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ),
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
              border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(row.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
                Expanded(child: Text(row.$2, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
