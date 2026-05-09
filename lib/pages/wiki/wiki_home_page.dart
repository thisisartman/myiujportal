import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wiki_provider.dart';
import '../../widgets/common/app_modal.dart';
import '../../widgets/common/page_chrome.dart';
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
        PageGreeting(
          title: 'Wiki',
          meta: const [
            MetaText('Courses, rooms, how-to guides and student knowledge'),
            MetaDot(),
            MetaText('Updated daily', emphasis: true),
          ],
          actions: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Create topic'),
                onPressed: () => _showCreateTopicModal(context, isCreate: true),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit topic'),
                onPressed: () =>
                    _showCreateTopicModal(context, isCreate: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SearchPanel(
          hint: 'Search wiki, courses, rooms, forms...',
          onChanged: (value) =>
              ref.read(wikiSearchQueryProvider.notifier).state = value,
          trailing: const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              MetaText('Popular:'),
              SoftChip(label: 'Course catalog'),
              SoftChip(label: 'Study room booking'),
              SoftChip(label: 'Dorm guides'),
              SoftChip(label: 'Report campus issue'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Explore Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Divider(height: 24),
        _categoryGrid(context),
      ],
    );
  }

  Widget _categoryGrid(BuildContext context) {
    final categories = [
      _CategoryCard(
        icon: Icons.book_outlined,
        iconBg: AppColors.tealTint2,
        iconColor: AppColors.primary,
        title: 'Courses',
        subtitle: 'Syllabi & Materials',
        path: '/wiki/category-courses',
      ),
      _CategoryCard(
        icon: Icons.home_outlined,
        iconBg: AppColors.successLight,
        iconColor: AppColors.success,
        title: 'Residential Life',
        subtitle: 'Dorms & Local Guides',
        path: '/wiki/category-residential-life',
      ),
      _CategoryCard(
        icon: Icons.school_outlined,
        iconBg: AppColors.warningLight,
        iconColor: AppColors.warning,
        title: 'Academics',
        subtitle: 'Procedures & Registration',
        path: '/wiki/category-academics',
      ),
      _CategoryCard(
        icon: Icons.group_outlined,
        iconBg: AppColors.dangerLight,
        iconColor: AppColors.danger,
        title: 'GSO',
        subtitle: 'Events & Organizations',
        path: '/wiki/category-gso',
      ),
    ];

    final isWide = MediaQuery.of(context).size.width >= 600;

    return GridView.count(
      crossAxisCount: isWide ? 3 : 1,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.15 : 3.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((c) => _buildCategoryTile(context, c)).toList(),
    );
  }

  Widget _buildCategoryTile(BuildContext context, _CategoryCard c) {
    return GestureDetector(
      onTap: () => context.go(c.path),
      child: Container(
        padding: const EdgeInsets.all(22),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(c.icon, color: c.iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              c.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            const Text(
              'Browse ->',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.tealInk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResults(
    BuildContext context,
    List<MapEntry<String, dynamic>> results,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} result(s) found',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...results.map(
          (entry) => GestureDetector(
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
                      Text(
                        entry.value.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        entry.value.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Student submissions are queued for moderation. Only Professors and OAA staff can publish directly.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
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
