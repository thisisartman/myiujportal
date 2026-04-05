import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sidebar_provider.dart';
import 'sidebar.dart';
import 'top_nav.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

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
          // Mobile: animated slide-in overlay
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
        ],
      ),
    );
  }
}
