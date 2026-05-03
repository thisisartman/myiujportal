import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../common/dashboard_card.dart';

class QuickLinksWidget extends ConsumerWidget {
  final String? style;

  const QuickLinksWidget({super.key, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String effectiveStyle = style ?? ref.watch(quickLinkStyleProvider);
    final links = _links;
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.apps_outlined,
        text: 'Quick links',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final config = _QuickLinkStyleConfig.from(effectiveStyle);
          final count = (constraints.maxWidth / config.minWidth).floor();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: links.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count < 1 ? 1 : count,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: config.tileHeight,
            ),
            itemBuilder: (context, index) {
              return _LinkTile(link: links[index], style: effectiveStyle);
            },
          );
        },
      ),
    );
  }
}

final _links = [
  const _Link(Icons.calendar_today_outlined, 'Calendar', '/calendar'),
  const _Link(Icons.business_outlined, 'Facilities', '/facilities'),
  const _Link(Icons.local_library_outlined, 'Wiki', '/wiki'),
  const _Link(Icons.badge_outlined, 'Digital ID', '/profile'),
  const _Link(Icons.groups_2_outlined, 'Meetings', '/meeting/SD1SYNC'),
  const _Link(Icons.menu_book_outlined, 'Library', '/facilities/library'),
];

class _Link {
  final IconData icon;
  final String label;
  final String path;

  const _Link(this.icon, this.label, this.path);
}

class _QuickLinkStyleConfig {
  final double minWidth;
  final double tileHeight;

  const _QuickLinkStyleConfig(this.minWidth, this.tileHeight);

  factory _QuickLinkStyleConfig.from(String style) {
    return switch (style) {
      'icon-only' => const _QuickLinkStyleConfig(58, 56),
      'cards' => const _QuickLinkStyleConfig(140, 60),
      _ => const _QuickLinkStyleConfig(100, 80),
    };
  }
}

class _LinkTile extends StatefulWidget {
  final _Link link;
  final String style;

  const _LinkTile({required this.link, required this.style});

  @override
  State<_LinkTile> createState() => _LinkTileState();
}

class _LinkTileState extends State<_LinkTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isCards = widget.style == 'cards';
    final isIconOnly = widget.style == 'icon-only';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go(widget.link.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _hovering ? -1 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: isCards ? 10 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.tealTint2 : AppColors.bgSunken,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovering ? AppColors.primary : AppColors.ruleSofter,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: isCards ? _cardsLayout() : _iconLayout(showLabel: !isIconOnly),
        ),
      ),
    );
  }

  Widget _iconLayout({required bool showLabel}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.link.icon, size: 28, color: AppColors.tealInk),
        if (showLabel) ...[
          const SizedBox(height: 7),
          Text(
            widget.link.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.ink2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _cardsLayout() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.tealTint2,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.link.icon, size: 20, color: AppColors.tealInk),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.link.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink2,
            ),
          ),
        ),
      ],
    );
  }
}
