import 'package:flutter/material.dart';
import 'top_nav.dart';
import '../../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TopNav(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                _pageGutter(context),
                24,
                _pageGutter(context),
                isMobile ? 88 : 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: SelectionArea(child: child),
                ),
              ),
            ),
          ),
          if (isMobile) const MobileNav(),
        ],
      ),
    );
  }

  double _pageGutter(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 480) return 16;
    if (width < 900) return 20;
    return width * 0.03;
  }
}
