import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';

class BreadcrumbBar extends StatelessWidget {
  final String pageId;
  const BreadcrumbBar({super.key, required this.pageId});

  @override
  Widget build(BuildContext context) {
    final page = kWikiPages[pageId];
    if (page == null || page.parentPage == null) return const SizedBox.shrink();

    final parent = kWikiPages[page.parentPage!];
    if (parent == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextButton.icon(
        onPressed: () => context.go('/wiki/${page.parentPage!}'),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: Text('Back to ${parent.title}'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
