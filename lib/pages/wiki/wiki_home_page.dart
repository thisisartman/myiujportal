import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wiki_provider.dart';
import '../../widgets/common/app_modal.dart';
import '../../theme/app_colors.dart';

class WikiHomePage extends ConsumerWidget {
  const WikiHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(wikiSearchResultsProvider);
    final searchQuery = ref.watch(wikiSearchQueryProvider);

    if (searchQuery.isNotEmpty && searchResults.isNotEmpty) {
      return _searchResults(context, searchResults);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wiki Knowledge Base', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text(
          'Find procedures, guides, course syllabi, and student-curated knowledge all in one place.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Create New Topic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showCreateTopicModal(context, isCreate: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                label: const Text('Edit Existing Topic', style: TextStyle(color: AppColors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                onPressed: () => _showCreateTopicModal(context, isCreate: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Explore Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Divider(height: 24),
        _categoryGrid(context),
      ],
    );
  }

  Widget _categoryGrid(BuildContext context) {
    final categories = [
      _CategoryCard(
        icon: Icons.book_outlined,
        iconBg: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF2563EB),
        title: 'Courses',
        subtitle: 'Syllabi & Materials',
        path: '/wiki/category-courses',
      ),
      _CategoryCard(
        icon: Icons.home_outlined,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        title: 'Residential Life',
        subtitle: 'Dorms & Local Guides',
        path: '/wiki/category-residential-life',
      ),
      _CategoryCard(
        icon: Icons.school_outlined,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        title: 'Academics',
        subtitle: 'Procedures & Registration',
        path: '/wiki/category-academics',
      ),
      _CategoryCard(
        icon: Icons.group_outlined,
        iconBg: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
        title: 'GSO',
        subtitle: 'Events & Organizations',
        path: '/wiki/category-gso',
      ),
    ];

    final isWide = MediaQuery.of(context).size.width >= 600;

    return GridView.count(
      crossAxisCount: isWide ? 2 : 1,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 3.5 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((c) => _buildCategoryTile(context, c)).toList(),
    );
  }

  Widget _buildCategoryTile(BuildContext context, _CategoryCard c) {
    return GestureDetector(
      onTap: () => context.go(c.path),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(c.icon, color: c.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(c.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _searchResults(BuildContext context, List<MapEntry<String, dynamic>> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${results.length} result(s) found', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...results.map((entry) => GestureDetector(
          onTap: () => context.go('/wiki/${entry.key}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.article_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(entry.value.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _showCreateTopicModal(BuildContext context, {required bool isCreate}) {
    final titleController = TextEditingController();
    bool submitted = false;

    AppModal.show(
      context,
      title: isCreate ? 'Create New Topic' : 'Suggest an Edit',
      child: StatefulBuilder(
        builder: (ctx, setState) {
          if (submitted) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 48),
                SizedBox(height: 12),
                Text(
                  'Submitted for Moderation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Your submission is pending review by an OAA administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // RBAC notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Student submissions are queued for moderation. Only Professors and OAA staff can publish directly.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Topic Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => submitted = true),
                    child: Text(isCreate ? 'Submit for Review' : 'Submit Edit'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String path;
  const _CategoryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.path,
  });
}
