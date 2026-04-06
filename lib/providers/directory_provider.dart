import 'package:flutter_riverpod/flutter_riverpod.dart';

final directorySearchProvider = StateProvider<String>((ref) => '');
final directoryFilterProvider = StateProvider<String>((ref) => 'All');
final expandedDirectoryEntryProvider = StateProvider<int?>((ref) => null);
