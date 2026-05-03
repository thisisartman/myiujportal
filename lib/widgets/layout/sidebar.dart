import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/sidebar_provider.dart';
import '../../providers/wiki_provider.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  bool _wikiExpanded = false;

  void _navigate(BuildContext context, String path) {
    context.go(path);
    ref.read(sidebarOpenProvider.notifier).state = false;
    if (path.startsWith('/wiki')) _wikiExpanded = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/wiki')) _wikiExpanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final expandedCategories = ref.watch(expandedCategoriesProvider);
    final expandedSubcategories = ref.watch(expandedSubcategoriesProvider);

    bool isActive(String path) {
      if (path == '/') return location == '/';
      return location.startsWith(path);
    }

    return Container(
      width: 256,
      decoration: const BoxDecoration(color: AppColors.sidebarBg),
      child: Column(
        children: [
          // Logo
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _navigate(context, '/'),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.sidebarDivider),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MyIUJ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    if (MediaQuery.of(context).size.width < 768)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              ref.read(sidebarOpenProvider.notifier).state =
                                  false,
                          child: const Icon(
                            Icons.close,
                            color: AppColors.sidebarInactive,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Nav items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Main'),
                  _navItem(
                    context,
                    '/',
                    Icons.dashboard_outlined,
                    'Dashboard',
                    isActive('/'),
                  ),
                  _navItem(
                    context,
                    '/calendar',
                    Icons.calendar_today_outlined,
                    'Calendar',
                    isActive('/calendar'),
                  ),
                  _navItem(
                    context,
                    '/facilities',
                    Icons.business_outlined,
                    'Facilities',
                    isActive('/facilities'),
                  ),
                  const SizedBox(height: 8),
                  _wikiHeader(context, isActive('/wiki')),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _wikiAccordion(
                      context,
                      expandedCategories,
                      expandedSubcategories,
                      location,
                    ),
                    crossFadeState: _wikiExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.sidebarSubtext,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String path,
    IconData icon,
    String label,
    bool active,
  ) {
    var hovering = false;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setLocalState(() => hovering = true),
          onExit: (_) => setLocalState(() => hovering = false),
          child: GestureDetector(
            onTap: () => _navigate(context, path),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: hovering
                    ? AppColors.sidebarHover
                    : (active ? AppColors.sidebarActiveBg : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: active
                    ? const Border(
                        left: BorderSide(
                          color: AppColors.sidebarActive,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: active
                        ? AppColors.sidebarActive
                        : AppColors.sidebarInactive,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: active
                          ? AppColors.sidebarActive
                          : AppColors.sidebarInactive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wikiHeader(BuildContext context, bool active) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      hoverColor: AppColors.sidebarHover,
      onTap: () {
        _navigate(context, '/wiki');
        setState(() => _wikiExpanded = true);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.sidebarActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? const Border(
                  left: BorderSide(color: AppColors.sidebarActive, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_library_outlined,
              size: 18,
              color: active
                  ? AppColors.sidebarActive
                  : AppColors.sidebarInactive,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wiki',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active
                      ? AppColors.sidebarActive
                      : AppColors.sidebarInactive,
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _wikiExpanded = !_wikiExpanded),
                child: Icon(
                  _wikiExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: AppColors.sidebarSubtext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wikiAccordion(
    BuildContext context,
    List<String> expandedCategories,
    List<String> expandedSubcategories,
    String location,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: kWikiCategories.map((cat) {
          final isExpanded = expandedCategories.contains(cat.name);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  context.go('/wiki/${cat.id}');
                  ref.read(sidebarOpenProvider.notifier).state = false;
                  if (!isExpanded) {
                    ref
                        .read(expandedCategoriesProvider.notifier)
                        .update((state) => [...state, cat.name]);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          cat.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: location.contains(cat.id)
                                ? AppColors.sidebarActive
                                : AppColors.sidebarInactive,
                          ),
                        ),
                      ),
                      if (cat.subcategories.isNotEmpty)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              final notifier = ref.read(
                                expandedCategoriesProvider.notifier,
                              );
                              notifier.update(
                                (state) => isExpanded
                                    ? state.where((c) => c != cat.name).toList()
                                    : [...state, cat.name],
                              );
                            },
                            child: Icon(
                              isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              size: 14,
                              color: AppColors.sidebarSubtext,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (cat.subcategories.isNotEmpty && isExpanded)
                ...cat.subcategories.map((sub) {
                  return InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      context.go('/wiki/subcategory-${sub.id}');
                      ref.read(sidebarOpenProvider.notifier).state = false;
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
                      child: Text(
                        sub.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: location.contains(sub.id)
                              ? AppColors.sidebarActive
                              : AppColors.sidebarInactive,
                        ),
                      ),
                    ),
                  );
                }),
              if (cat.subcategories.isEmpty)
                ...(_getCategoryPages(cat.id).map(
                  (pageEntry) => InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      context.go('/wiki/${pageEntry.key}');
                      ref.read(sidebarOpenProvider.notifier).state = false;
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
                      child: Text(
                        pageEntry.value.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: location.contains(pageEntry.key)
                              ? AppColors.sidebarActive
                              : AppColors.sidebarInactive,
                        ),
                      ),
                    ),
                  ),
                )),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _getCategoryPages(String categoryId) {
    final categoryName = kWikiCategories
        .firstWhere((c) => c.id == categoryId)
        .name;
    return kWikiPages.entries.where((e) {
      return !e.value.isLandingPage && e.value.category == categoryName;
    }).toList();
  }
}
