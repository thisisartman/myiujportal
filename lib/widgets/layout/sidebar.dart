import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sidebar_provider.dart';
import '../../providers/wiki_provider.dart';
import '../../data/mock_data.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF4F46E5), size: 24),
                const SizedBox(width: 8),
                Text(
                  'MyIUJ!',
                  style: TextStyle(
                    color: const Color(0xFF4338CA),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (MediaQuery.of(context).size.width < 768)
                  GestureDetector(
                    onTap: () => ref.read(sidebarOpenProvider.notifier).state = false,
                    child: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                  ),
              ],
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
                  _navItem(context, '/', Icons.dashboard_outlined, 'Dashboard', isActive('/')),
                  _navItem(context, '/calendar', Icons.calendar_today_outlined, 'Calendar', isActive('/calendar')),
                  _navItem(context, '/facilities', Icons.business_outlined, 'Facilities', isActive('/facilities')),
                  const SizedBox(height: 8),
                  // Wiki accordion header
                  _wikiHeader(context, isActive('/wiki')),
                  // Wiki accordion body
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _wikiAccordion(context, expandedCategories, expandedSubcategories, location),
                    crossFadeState: _wikiExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
          ),
          // Logout
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: InkWell(
              onTap: () {
                ref.read(authProvider.notifier).logout();
                ref.read(sidebarOpenProvider.notifier).state = false;
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Color(0xFF6B7280)),
                    SizedBox(width: 12),
                    Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String path, IconData icon, String label, bool active) {
    return InkWell(
      onTap: () => _navigate(context, path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF2FF) : Colors.transparent,
          border: Border(
            right: active
                ? const BorderSide(color: Color(0xFF4F46E5), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? const Color(0xFF4F46E5) : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wikiHeader(BuildContext context, bool active) {
    return InkWell(
      onTap: () {
        _navigate(context, '/wiki');
        setState(() => _wikiExpanded = true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF2FF) : Colors.transparent,
          border: Border(
            right: active
                ? const BorderSide(color: Color(0xFF4F46E5), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.local_library_outlined, size: 18, color: active ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wiki',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active ? const Color(0xFF4F46E5) : const Color(0xFF4B5563),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _wikiExpanded = !_wikiExpanded),
              child: Icon(
                _wikiExpanded ? Icons.chevron_right : Icons.chevron_right,
                size: 18,
                color: const Color(0xFF9CA3AF),
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
      margin: const EdgeInsets.only(left: 16, right: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          left: BorderSide(color: Color(0xFFC7D2FE), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: kWikiCategories.map((cat) {
          final isExpanded = expandedCategories.contains(cat.name);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Category header
              InkWell(
                onTap: () {
                  context.go('/wiki/${cat.id}');
                  ref.read(sidebarOpenProvider.notifier).state = false;
                  if (!isExpanded) {
                    ref.read(expandedCategoriesProvider.notifier).update(
                      (state) => [...state, cat.name],
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      if (cat.subcategories.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            final notifier = ref.read(expandedCategoriesProvider.notifier);
                            notifier.update((state) => isExpanded
                                ? state.where((c) => c != cat.name).toList()
                                : [...state, cat.name]);
                          },
                          child: Icon(
                            isExpanded ? Icons.expand_more : Icons.chevron_right,
                            size: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Subcategories
              if (cat.subcategories.isNotEmpty && isExpanded)
                ...cat.subcategories.map((sub) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          context.go('/wiki/subcategory-${sub.id}');
                          ref.read(sidebarOpenProvider.notifier).state = false;
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: location.contains(sub.id)
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              // Non-subcategory pages (residential life, academics, etc.)
              if (cat.subcategories.isEmpty) ...[
                // Show leaf pages for residential-life and academics
                ...(_getCategoryPages(cat.id).map((pageEntry) => InkWell(
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
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ))),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _getCategoryPages(String categoryId) {
    final categoryName = kWikiCategories.firstWhere((c) => c.id == categoryId).name;
    return kWikiPages.entries.where((e) {
      return !e.value.isLandingPage && e.value.category == categoryName;
    }).toList();
  }
}
