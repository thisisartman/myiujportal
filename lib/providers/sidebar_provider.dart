import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile: drawer open/closed
final sidebarOpenProvider = StateProvider<bool>((ref) => false);

/// Desktop: icon-only collapsed state
final desktopCollapsedProvider = StateProvider<bool>((ref) => false);
