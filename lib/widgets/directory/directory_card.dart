import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/wiki_page.dart';
import '../../providers/directory_provider.dart';

class DirectoryCard extends ConsumerWidget {
  final DirectoryEntry entry;

  const DirectoryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedId = ref.watch(expandedDirectoryEntryProvider);
    final isExpanded = expandedId == entry.id;

    return GestureDetector(
      onTap: () {
        ref.read(expandedDirectoryEntryProvider.notifier).state =
            isExpanded ? null : entry.id;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Avatar(name: entry.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                        const SizedBox(height: 3),
                        _TypeChip(type: entry.type),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF9CA3AF), size: 18),
                ],
              ),
            ),
            if (isExpanded) _ExpandedDetails(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final DirectoryEntry entry;
  const _ExpandedDetails({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          if (entry.studentId != null) _row('Student ID', entry.studentId!),
          if (entry.email.isNotEmpty) _row('Email', entry.email),
          if (entry.phone.isNotEmpty) _row('Phone', entry.phone),
          if (entry.coordinator != null) _row('Coordinator', entry.coordinator!),
          if (entry.type == 'Organization') ...[
            const SizedBox(height: 10),
            _WikiLink(entry: entry),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF111827))),
          ),
        ],
      ),
    );
  }
}

class _WikiLink extends StatelessWidget {
  final DirectoryEntry entry;
  const _WikiLink({required this.entry});

  String _wikiId() {
    final name = entry.name.toLowerCase();
    if (name.contains('gso') || name.contains('graduate student')) return 'gso';
    if (name.contains('gsim')) return 'gsim-council';
    if (name.contains('gsir')) return 'gsir-council';
    return 'clubs';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/wiki/${_wikiId()}'),
      child: const Row(
        children: [
          Icon(Icons.open_in_new, size: 14, color: Color(0xFF4F46E5)),
          SizedBox(width: 6),
          Text('View Wiki page', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Text(_initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  Color get _color {
    if (type.startsWith('Faculty')) return const Color(0xFF7C3AED);
    if (type == 'Student') return const Color(0xFF2563EB);
    if (type == 'Organization') return const Color(0xFF16A34A);
    if (type == 'Department') return const Color(0xFFD97706);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type, style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w500)),
    );
  }
}
