import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/wiki_pages.dart';
import '../../models/wiki_page.dart';
import '../../providers/wiki_provider.dart';
import '../../widgets/common/page_chrome.dart';
import '../../theme/app_colors.dart';

// ── Category definitions ──────────────────────────────────────────────────────

class _WikiCategoryMeta {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _WikiCategoryMeta({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

const _kCategories = [
  _WikiCategoryMeta(
    id: 'Residential Life',
    title: 'Residential Life',
    subtitle: 'Dorms, transport & daily living',
    icon: Icons.home_outlined,
    iconBg: AppColors.successLight,
    iconColor: AppColors.success,
  ),
  _WikiCategoryMeta(
    id: 'Academics',
    title: 'Academics',
    subtitle: 'GSIM, GSIR, programs & procedures',
    icon: Icons.school_outlined,
    iconBg: AppColors.primaryLight,
    iconColor: AppColors.primary,
  ),
  _WikiCategoryMeta(
    id: 'Campus Life',
    title: 'Campus Life',
    subtitle: 'Clubs, events & organizations',
    icon: Icons.group_outlined,
    iconBg: AppColors.warningLight,
    iconColor: AppColors.warning,
  ),
  _WikiCategoryMeta(
    id: 'Administration',
    title: 'Administration',
    subtitle: 'Admissions, immigration, finance & services',
    icon: Icons.account_balance_outlined,
    iconBg: AppColors.dangerLight,
    iconColor: AppColors.danger,
  ),
];

// ── Static content lists ──────────────────────────────────────────────────────

final _kFeaturedArticles = [
  (id: '01-Residential-Life--dorm-guide', label: 'Dorm Guide'),
  (id: '02-Academics--gsim--program-mba', label: 'MBA Program'),
  (id: '04-Administration--immigration--visa-extensions', label: 'Visa Extensions'),
  (id: '04-Administration--library--library-overview', label: 'MLIC Library'),
  (id: '01-Residential-Life--getting-to-iuj', label: 'Getting to IUJ'),
  (id: '03-Campus-Life-and-Organizations--student-organizations', label: 'Student Organizations'),
];

final _kPopularArticles = [
  (id: '01-Residential-Life--september-arrival-guide', label: 'September Arrival Guide', category: 'Residential Life'),
  (id: '02-Academics--gsim--program-imba', label: 'Intensive MBA Program', category: 'Academics'),
  (id: '03-Campus-Life-and-Organizations--clubs-and-events', label: 'Clubs & Events', category: 'Campus Life'),
  (id: '04-Administration--admissions-enrollment--tuition-scholarships', label: 'Tuition & Scholarships', category: 'Administration'),
  (id: '01-Residential-Life--bus-train-schedules', label: 'Bus & Train Schedules', category: 'Residential Life'),
  (id: '04-Administration--financial--cost-of-attendance', label: 'Cost of Attendance', category: 'Administration'),
];

// ── Home page ─────────────────────────────────────────────────────────────────

class WikiHomePage extends ConsumerWidget {
  const WikiHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(wikiSearchQueryProvider);
    final searchResults = ref.watch(wikiSearchResultsProvider);
    final activeFilter = ref.watch(wikiCategoryFilterProvider);

    final visibleCategories = activeFilter == null
        ? _kCategories
        : _kCategories.where((c) => c.id == activeFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Wiki',
          meta: const [
            MetaText('Campus knowledge base · 118 articles'),
            MetaDot(),
            MetaText('Updated daily', emphasis: true),
          ],
        ),
        const SizedBox(height: 18),
        SearchPanel(
          hint: 'Search wiki — dorms, programs, immigration, clubs…',
          onChanged: (v) =>
              ref.read(wikiSearchQueryProvider.notifier).state = v,
          trailing: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SoftChip(
                label: 'All',
                selected: activeFilter == null,
                onTap: () =>
                    ref.read(wikiCategoryFilterProvider.notifier).state = null,
              ),
              ..._kCategories.map(
                (c) => SoftChip(
                  label: c.title,
                  selected: activeFilter == c.id,
                  onTap: () => ref.read(wikiCategoryFilterProvider.notifier).state =
                      activeFilter == c.id ? null : c.id,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (searchQuery.isNotEmpty) ...[
          _SearchResults(results: searchResults, query: searchQuery),
          const SizedBox(height: 28),
        ],
        // Explore Categories — compact horizontal row
        const _SectionLabel('Explore Categories'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _kCategories.indexed.map((entry) {
              final (i, c) = entry;
              return Padding(
                padding: EdgeInsets.only(right: i < _kCategories.length - 1 ? 10 : 0),
                child: _CompactCategoryCard(
                  meta: c,
                  isActive: activeFilter == c.id,
                  onTap: () => ref.read(wikiCategoryFilterProvider.notifier).state =
                      activeFilter == c.id ? null : c.id,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 28),
        // Featured Articles
        const _SectionLabel('Featured Articles'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kFeaturedArticles
              .map((a) => SoftChip(
                    label: a.label,
                    onTap: () => context.go('/wiki/${a.id}'),
                  ))
              .toList(),
        ),
        const SizedBox(height: 28),
        // Popular / Recommended
        const _SectionLabel('Popular'),
        const SizedBox(height: 10),
        ..._kPopularArticles.map((a) => _PopularTile(
              id: a.id,
              label: a.label,
              categoryId: a.category,
            )),
        const SizedBox(height: 28),
        // Per-category article sections (filtered)
        ...visibleCategories.map((c) => _CategorySection(meta: c)),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final List<MapEntry<String, WikiPage>> results;
  final String query;
  const _SearchResults({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Text(
        'No results for "$query".',
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...results.map((e) => _ArticleTile(pageId: e.key, page: e.value)),
      ],
    );
  }
}

// ── Compact category card (horizontal row) ────────────────────────────────────

class _CompactCategoryCard extends StatefulWidget {
  final _WikiCategoryMeta meta;
  final bool isActive;
  final VoidCallback onTap;

  const _CompactCategoryCard({
    required this.meta,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CompactCategoryCard> createState() => _CompactCategoryCardState();
}

class _CompactCategoryCardState extends State<_CompactCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    final count = kWikiPages.values.where((p) => p.category == meta.id).length;
    final active = widget.isActive || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 196,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.ruleSoft,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: meta.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(meta.icon, color: meta.iconColor, size: 17),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meta.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$count articles',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Popular tile ──────────────────────────────────────────────────────────────

class _PopularTile extends StatelessWidget {
  final String id;
  final String label;
  final String categoryId;

  const _PopularTile({
    required this.id,
    required this.label,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final catMeta = _kCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => _kCategories.first,
    );
    return GestureDetector(
      onTap: () => context.go('/wiki/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ruleSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: catMeta.iconBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categoryId,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: catMeta.iconColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Per-category article list ─────────────────────────────────────────────────

class _CategorySection extends StatefulWidget {
  final _WikiCategoryMeta meta;
  const _CategorySection({required this.meta});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final articles = kWikiPages.entries
        .where((e) => e.value.category == widget.meta.id)
        .toList()
      ..sort((a, b) => a.value.title.compareTo(b.value.title));

    final visible = _expanded ? articles : articles.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.meta.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.meta.icon,
                  color: widget.meta.iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              widget.meta.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...visible.map((e) => _ArticleTile(pageId: e.key, page: e.value)),
        if (articles.length > 6)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? 'Show less'
                  : 'Show all ${articles.length} articles →',
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Article tile ──────────────────────────────────────────────────────────────

class _ArticleTile extends StatelessWidget {
  final String pageId;
  final WikiPage page;
  const _ArticleTile({required this.pageId, required this.page});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/wiki/$pageId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ruleSoft),
        ),
        child: Row(
          children: [
            const Icon(Icons.article_outlined,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                page.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (page.subcategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgSunken,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  page.subcategory!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
