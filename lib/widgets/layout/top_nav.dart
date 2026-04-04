import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sidebar_provider.dart';
import '../../providers/wiki_provider.dart';

class TopNav extends ConsumerWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final searchQuery = ref.watch(wikiSearchQueryProvider);

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Hamburger (mobile) or collapse button (desktop)
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF374151)),
              onPressed: () => ref.read(sidebarOpenProvider.notifier).state = true,
            )
          else
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF374151)),
              onPressed: () => ref.read(desktopCollapsedProvider.notifier).update((s) => !s),
            ),
          const SizedBox(width: 8),
          // Search bar
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.search, size: 16, color: Color(0xFF9CA3AF)),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => ref.read(wikiSearchQueryProvider.notifier).state = v,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search wiki...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                      onPressed: () => ref.read(wikiSearchQueryProvider.notifier).state = '',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4F46E5),
            child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
