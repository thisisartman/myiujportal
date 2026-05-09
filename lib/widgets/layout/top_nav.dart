import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/wiki_provider.dart';
import '../../theme/app_colors.dart';
import '../common/toast_overlay.dart';
import '../dashboard/profile_dropdown.dart';

class TopNav extends ConsumerWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final showFullNav = width >= 860;
    final showSearch = width >= 720;
    final location = GoRouterState.of(context).uri.toString();
    final query = ref.watch(wikiSearchQueryProvider);

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: width < 520 ? 14 : width * .03),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.ruleSoft)),
      ),
      child: Row(
        children: [
          _Brand(onTap: () => context.go('/')),
          if (showFullNav) ...[
            const SizedBox(width: 18),
            _TopNavLink(
              label: 'Dashboard',
              path: '/',
              icon: Icons.dashboard_outlined,
              active: location == '/',
            ),
            _TopNavLink(
              label: 'Calendar',
              path: '/calendar',
              icon: Icons.calendar_today_outlined,
              active: location.startsWith('/calendar'),
            ),
            _TopNavLink(
              label: 'Facilities',
              path: '/facilities',
              icon: Icons.business_outlined,
              active: location.startsWith('/facilities'),
            ),
            _TopNavLink(
              label: 'Wiki',
              path: '/wiki',
              icon: Icons.local_library_outlined,
              active: location.startsWith('/wiki'),
            ),
          ],
          const Spacer(),
          if (showSearch)
            Flexible(
              flex: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _SearchBox(query: query, ref: ref),
              ),
            ),
          if (showSearch) const SizedBox(width: 12),
          _AlertButton(),
          const SizedBox(width: 10),
          const ProfileChip(),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final VoidCallback onTap;

  const _Brand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text.rich(
              TextSpan(
                text: 'MyIUJ',
                children: [
                  TextSpan(
                    text: '!',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavLink extends StatefulWidget {
  final String label;
  final String path;
  final IconData icon;
  final bool active;

  const _TopNavLink({
    required this.label,
    required this.path,
    required this.icon,
    required this.active,
  });

  @override
  State<_TopNavLink> createState() => _TopNavLinkState();
}

class _TopNavLinkState extends State<_TopNavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.bgSunken : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active
                ? const Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String query;
  final WidgetRef ref;

  const _SearchBox({required this.query, required this.ref});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.bgSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, size: 15, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  ref.read(wikiSearchQueryProvider.notifier).state = value,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search wiki, courses, people, rooms...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 15,
                color: AppColors.textMuted,
              ),
              onPressed: () =>
                  ref.read(wikiSearchQueryProvider.notifier).state = '',
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.ruleSoft),
              ),
              child: const Text(
                '⌘K',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifications',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () =>
                showToast(context, '3 unread alerts', type: ToastType.info),
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileNav extends StatelessWidget {
  const MobileNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return SafeArea(
      top: false,
      child: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.ruleSoft)),
        ),
        child: Row(
          children: [
            _MobileNavItem(
              label: 'Home',
              icon: Icons.dashboard_outlined,
              path: '/',
              active: location == '/',
            ),
            _MobileNavItem(
              label: 'Calendar',
              icon: Icons.calendar_today_outlined,
              path: '/calendar',
              active: location.startsWith('/calendar'),
            ),
            _MobileNavItem(
              label: 'Spaces',
              icon: Icons.business_outlined,
              path: '/facilities',
              active: location.startsWith('/facilities'),
            ),
            _MobileNavItem(
              label: 'Wiki',
              icon: Icons.local_library_outlined,
              path: '/wiki',
              active: location.startsWith('/wiki'),
            ),
            _MobileNavItem(
              label: 'Me',
              icon: Icons.person_outline,
              path: '/profile',
              active: location.startsWith('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String path;
  final bool active;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => context.go(path),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
