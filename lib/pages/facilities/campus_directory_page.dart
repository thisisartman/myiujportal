import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../providers/directory_provider.dart';
import '../../widgets/directory/directory_card.dart';

const _filterChips = ['All', 'Student', 'Faculty', 'Staff', 'Department', 'Organization'];

class CampusDirectoryPage extends ConsumerWidget {
  const CampusDirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(directorySearchProvider);
    final filter = ref.watch(directoryFilterProvider);

    final filtered = kMockDirectory.where((e) {
      final matchesFilter = filter == 'All' ||
          e.type == filter ||
          (filter == 'Faculty' && e.type.startsWith('Faculty')) ||
          (filter == 'Staff' && (e.type == 'Support' || e.type == 'Facility' || e.type == 'Satellite Office'));
      final matchesQuery = query.isEmpty ||
          e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.email.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    final mainEntries = filtered.where((e) => e.type != 'Organization').toList();
    final orgs = filtered.where((e) => e.type == 'Organization').toList();
    final showOrgs = filter == 'All' || filter == 'Organization';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/facilities'),
              child: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            const Text('Campus Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => ref.read(directorySearchProvider.notifier).state = v,
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterChips.map((chip) {
              final isActive = filter == chip;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(chip),
                  selected: isActive,
                  onSelected: (_) {
                    ref.read(directoryFilterProvider.notifier).state = chip;
                    ref.read(expandedDirectoryEntryProvider.notifier).state = null;
                  },
                  selectedColor: const Color(0xFFEEF2FF),
                  checkmarkColor: const Color(0xFF4F46E5),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF374151),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (mainEntries.isEmpty && orgs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('No results found.', style: TextStyle(color: Color(0xFF9CA3AF))),
            ),
          )
        else ...[
          ...mainEntries.map((e) => DirectoryCard(entry: e)),
          if (showOrgs && orgs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Organisations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
            const SizedBox(height: 12),
            ...orgs.map((e) => DirectoryCard(entry: e)),
          ],
        ],
      ],
    );
  }
}
