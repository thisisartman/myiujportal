# UI Polish & Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add hover effects, pointer cursor, sidebar slide animation, fix broken wiki category links, and wire the profile button to a profile page.

**Architecture:** All changes are self-contained widget-layer fixes. The sidebar animation moves from instant show/hide to `SlideTransition` on mobile. Hover/cursor effects are applied via a shared `HoverCard` helper and `MouseRegion` wrappers on `GestureDetector` usages. Wiki fix is a one-line fallback lookup. Profile page is a new route + simple widget.

**Tech Stack:** Flutter 3.41.4, go_router ^14.x, flutter_riverpod ^2.6.1

---

## File Map

| Action | File | Change |
|--------|------|--------|
| Create | `lib/widgets/common/hover_card.dart` | Reusable hover-aware container |
| Modify | `lib/widgets/layout/app_shell.dart` | Mobile slide animation |
| Modify | `lib/widgets/layout/top_nav.dart` | Profile button → `/profile` link |
| Modify | `lib/widgets/layout/sidebar.dart` | Remove last `Padding` right border on active items; already has hover via InkWell — add cursor |
| Modify | `lib/pages/dashboard_page.dart` | Wrap `GestureDetector` quick-action tiles in `MouseRegion` + hover effect |
| Modify | `lib/pages/wiki/wiki_article_page.dart` | Fallback `kWikiPages['category-$id']` lookup; wrap `GestureDetector` tiles |
| Modify | `lib/router/app_router.dart` | Add `/profile` route |
| Create | `lib/pages/profile_page.dart` | Hardcoded profile card |

---

## Task 1: Shared `HoverCard` widget

**Files:**
- Create: `lib/widgets/common/hover_card.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/widgets/common/hover_card.dart
import 'package:flutter/material.dart';

/// A container that darkens its border and background on hover.
/// Wrap any tappable card with this instead of a plain Container.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color hoverColor;
  final Color baseBorderColor;
  final Color hoverBorderColor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.baseColor = Colors.white,
    this.hoverColor = const Color(0xFFF5F3FF),
    this.baseBorderColor = const Color(0xFFE5E7EB),
    this.hoverBorderColor = const Color(0xFF4F46E5),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovering ? widget.hoverColor : widget.baseColor,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _hovering ? widget.hoverBorderColor : widget.baseBorderColor,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/common/hover_card.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/common/hover_card.dart
git commit -m "feat: add HoverCard shared widget with animated hover state"
```

---

## Task 2: Pointer cursor on sidebar nav items

The sidebar uses `InkWell` for nav items — Flutter 3.x `InkWell` already sets `SystemMouseCursors.click` on web automatically. But `GestureDetector` in the wiki accordion does not. Fix those.

**Files:**
- Modify: `lib/widgets/layout/sidebar.dart`

- [ ] **Step 1: Wrap wiki accordion GestureDetectors with cursor**

In `sidebar.dart`, every `GestureDetector` and `InkWell` inside `_wikiAccordion` and `_wikiHeader` needs `mouseCursor: SystemMouseCursors.click` (for `InkWell`) or a `MouseRegion` wrap (for `GestureDetector`).

Find every `GestureDetector(` in `sidebar.dart` and replace with this pattern:

```dart
// BEFORE
GestureDetector(
  onTap: () { ... },
  child: Padding(...),
)

// AFTER
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: () { ... },
    child: Padding(...),
  ),
)
```

There are 3 `GestureDetector` usages in `sidebar.dart`: the close-icon (line ~71), the wiki accordion expand toggle (line ~185), and the category expand toggle (line ~251). Update all three.

Also add `mouseCursor: SystemMouseCursors.click` to each `InkWell` in `_navItem` and `_wikiHeader`:

```dart
// In _navItem:
InkWell(
  mouseCursor: SystemMouseCursors.click,
  onTap: () => _navigate(context, path),
  ...
)

// In _wikiHeader:
InkWell(
  mouseCursor: SystemMouseCursors.click,
  onTap: () { ... },
  ...
)
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/layout/sidebar.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/layout/sidebar.dart
git commit -m "feat: add pointer cursor to sidebar nav items and wiki accordion"
```

---

## Task 3: Dashboard quick-action tiles — hover effect + pointer cursor

**Files:**
- Modify: `lib/pages/dashboard_page.dart`

- [ ] **Step 1: Replace GestureDetector+Container tiles with HoverCard**

In `dashboard_page.dart`, `_quickActions` method, replace:

```dart
// BEFORE
GestureDetector(
  onTap: () => context.go(a.path),
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column( ... ),
  ),
)

// AFTER
HoverCard(
  onTap: () => context.go(a.path),
  padding: const EdgeInsets.symmetric(vertical: 16),
  child: Column( ... ),
)
```

Add import at top:
```dart
import '../widgets/common/hover_card.dart';
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/pages/dashboard_page.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/pages/dashboard_page.dart
git commit -m "feat: hover effect on dashboard quick-action tiles"
```

---

## Task 4: Wiki article tiles — hover effect + pointer cursor

**Files:**
- Modify: `lib/pages/wiki/wiki_article_page.dart`

- [ ] **Step 1: Replace GestureDetector+Container in _CoursesCategory with HoverCard**

Add import:
```dart
import '../../widgets/common/hover_card.dart';
```

In `_subcategoryTile` method, replace:

```dart
// BEFORE
return GestureDetector(
  onTap: () => ctx.go('/wiki/$id'),
  child: Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row( ... ),
  ),
);

// AFTER
return HoverCard(
  onTap: () => ctx.go('/wiki/$id'),
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
  child: Row( ... ),
);
// remove the `margin` — add SizedBox(height: 8) after each tile instead
```

Do the same for `_SubcategoryPage` course tiles, `_ResidentialLifeCategory` tiles, `_AcademicsCategory` tiles, `_AdminCategory` tiles, and the `_ResearchCentersArticle` tiles.

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/pages/wiki/wiki_article_page.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/pages/wiki/wiki_article_page.dart
git commit -m "feat: hover effect on all wiki navigation tiles"
```

---

## Task 5: Fix broken wiki category links

**Problem:** Sidebar links go to `/wiki/courses`, `/wiki/residential-life`, etc. But `kWikiPages` only has keys like `category-courses`. So these routes show "Page Not Found".

**Fix:** In `WikiArticlePage._buildContent`, fall back to `category-$id` if `id` not found directly. Also update the `build` method page lookup.

**Files:**
- Modify: `lib/pages/wiki/wiki_article_page.dart`

- [ ] **Step 1: Fix page lookup in WikiArticlePage.build**

```dart
// BEFORE (line ~15)
final page = kWikiPages[articleId];

// AFTER
final page = kWikiPages[articleId] ?? kWikiPages['category-$articleId'];
```

- [ ] **Step 2: Fix _buildContent switch to handle short IDs**

At the top of `_buildContent`, normalize the id:

```dart
Widget _buildContent(BuildContext context, String id) {
  // Support both 'courses' and 'category-courses' as the same page
  final normalizedId = kWikiPages.containsKey(id) ? id : 'category-$id';

  switch (normalizedId) {
    case 'category-courses':
      return _CoursesCategory(context: context);
    // ... rest unchanged, all using normalizedId
```

- [ ] **Step 3: Analyze**

```bash
dart analyze lib/pages/wiki/wiki_article_page.dart
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/pages/wiki/wiki_article_page.dart
git commit -m "fix: wiki category URLs now resolve (courses, residential-life, etc.)"
```

---

## Task 6: Mobile sidebar — slide-in animation

**Problem:** On mobile, the sidebar overlay `Positioned` widget appears instantly with no animation.

**Fix:** Replace the raw `Positioned` with an `AnimatedSlide` (or `SlideTransition`) so it slides in from the left.

**Files:**
- Modify: `lib/widgets/layout/app_shell.dart`

- [ ] **Step 1: Replace instant overlay with animated drawer**

Replace the entire `AppShell.build` method:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final isDesktopCollapsed = ref.watch(desktopCollapsedProvider);
  final isMobileOpen = ref.watch(sidebarOpenProvider);
  final isDesktop = MediaQuery.of(context).size.width >= 768;

  return Scaffold(
    backgroundColor: const Color(0xFFF9FAFB),
    body: Stack(
      children: [
        Row(
          children: [
            // Desktop sidebar — animates width
            if (isDesktop)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: isDesktopCollapsed ? 0 : 256,
                child: isDesktopCollapsed ? const SizedBox.shrink() : const Sidebar(),
              ),
            // Main content
            Expanded(
              child: Column(
                children: [
                  TopNav(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Mobile: slide-in overlay
        if (!isDesktop) ...[
          AnimatedOpacity(
            opacity: isMobileOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !isMobileOpen,
              child: GestureDetector(
                onTap: () => ref.read(sidebarOpenProvider.notifier).state = false,
                child: Container(color: Colors.black54),
              ),
            ),
          ),
          AnimatedSlide(
            offset: isMobileOpen ? Offset.zero : const Offset(-1, 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: const Positioned(
              left: 0, top: 0, bottom: 0,
              child: Sidebar(),
            ),
          ),
        ],
      ],
    ),
  );
}
```

Note: `AnimatedSlide` does not work directly on `Positioned`. Use this pattern instead — replace the mobile block with:

```dart
if (!isDesktop) ...[
  // Backdrop
  AnimatedOpacity(
    opacity: isMobileOpen ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 200),
    child: IgnorePointer(
      ignoring: !isMobileOpen,
      child: GestureDetector(
        onTap: () => ref.read(sidebarOpenProvider.notifier).state = false,
        child: Container(color: Colors.black54),
      ),
    ),
  ),
  // Slide-in drawer
  Positioned(
    left: 0, top: 0, bottom: 0,
    child: AnimatedSlide(
      offset: isMobileOpen ? Offset.zero : const Offset(-1, 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: const Sidebar(),
    ),
  ),
],
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/layout/app_shell.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/layout/app_shell.dart
git commit -m "feat: mobile sidebar slides in/out with animation"
```

---

## Task 7: Profile page + wire avatar button

**Files:**
- Create: `lib/pages/profile_page.dart`
- Modify: `lib/widgets/layout/top_nav.dart`
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: Create profile_page.dart**

```dart
// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF4F46E5),
                child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              const Text('Student', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const Text('student@iuj.ac.jp', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _infoCard([
          ('Program', 'MBA — Graduate School of International Management'),
          ('Student ID', 'IUJ-2026-0001'),
          ('Year', '1st Year'),
          ('Status', 'Full-time'),
        ]),
        const SizedBox(height: 16),
        _infoCard([
          ('Adviser', 'Prof. Remy Magnier-Watanabe'),
          ('Campus Address', 'Dorm A, Room 201'),
        ]),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: rows.indexed.map((entry) {
          final (i, row) = entry;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(row.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ),
                Expanded(child: Text(row.$2, style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Add `/profile` to router**

In `lib/router/app_router.dart`, add inside the `ShellRoute` routes list:

```dart
import '../pages/profile_page.dart'; // add this import at the top

// Inside ShellRoute routes:
GoRoute(
  path: '/profile',
  pageBuilder: (context, state) =>
      const NoTransitionPage(child: ProfilePage()),
),
```

- [ ] **Step 3: Wire TopNav avatar to profile page**

In `lib/widgets/layout/top_nav.dart`, add `go_router` import and wrap the avatar:

```dart
import 'package:go_router/go_router.dart'; // add this

// Replace the CircleAvatar widget:
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: () => context.go('/profile'),
    child: CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF4F46E5),
      child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
    ),
  ),
),
```

- [ ] **Step 4: Analyze all changed files**

```bash
dart analyze lib/pages/profile_page.dart lib/router/app_router.dart lib/widgets/layout/top_nav.dart
```
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/pages/profile_page.dart lib/router/app_router.dart lib/widgets/layout/top_nav.dart
git commit -m "feat: profile page with sign-out; avatar button navigates to /profile"
```

---

## Task 8: Final full-project check

- [ ] **Step 1: Full analyze**

```bash
dart analyze lib/
```
Expected: only pre-existing `deprecated_member_use` infos. No new errors or warnings.

- [ ] **Step 2: Run in browser and verify**

```bash
flutter run -d chrome
```

Manually verify:
- [ ] Hovering any wiki tile shows indigo border + light purple bg
- [ ] Hovering quick-action tiles shows border highlight
- [ ] All clickable areas show pointer cursor
- [ ] Mobile: tap hamburger → sidebar slides in from left; backdrop fades in
- [ ] Mobile: tap backdrop or close → sidebar slides out
- [ ] Desktop: toggle hamburger → sidebar width animates to 0 and back
- [ ] Sidebar: `/wiki/courses` no longer shows "Page Not Found"
- [ ] Top-nav avatar click → navigates to `/profile`
- [ ] Profile page shows student info and sign-out button
