import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickLinksWidget extends StatelessWidget {
  const QuickLinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      _Link(Icons.calendar_today_outlined, 'Calendar', const Color(0xFF4F46E5), const Color(0xFFEEF2FF), '/calendar'),
      _Link(Icons.business_outlined, 'Facilities', const Color(0xFF059669), const Color(0xFFDCFCE7), '/facilities'),
      _Link(Icons.local_library_outlined, 'Wiki', const Color(0xFF0891B2), const Color(0xFFCFFAFE), '/wiki'),
      _Link(Icons.badge_outlined, 'Digital ID', const Color(0xFF7C3AED), const Color(0xFFF5F3FF), '/profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Links', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: links.map((l) => _LinkTile(link: l)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Link {
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final String path;
  const _Link(this.icon, this.label, this.fg, this.bg, this.path);
}

class _LinkTile extends StatefulWidget {
  final _Link link;
  const _LinkTile({required this.link});
  @override
  State<_LinkTile> createState() => _LinkTileState();
}

class _LinkTileState extends State<_LinkTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.link;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go(l.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? l.bg : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hovering ? l.fg : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(l.icon, color: l.fg, size: 18),
              const SizedBox(width: 8),
              Text(l.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _hovering ? l.fg : const Color(0xFF374151))),
            ],
          ),
        ),
      ),
    );
  }
}
