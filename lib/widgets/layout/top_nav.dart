import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/sidebar_provider.dart';
import '../../providers/wiki_provider.dart';
import '../../theme/app_colors.dart';

class TopNav extends ConsumerWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final searchQuery = ref.watch(wikiSearchQueryProvider);

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textSecondary),
            onPressed: isDesktop
                ? () => ref.read(desktopCollapsedProvider.notifier).update((s) => !s)
                : () => ref.read(sidebarOpenProvider.notifier).state = true,
          ),
          const SizedBox(width: 8),
          // Pill search bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search, size: 16, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => ref.read(wikiSearchQueryProvider.notifier).state = v,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search wiki...',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      onPressed: () => ref.read(wikiSearchQueryProvider.notifier).state = '',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User avatar
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('S', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
