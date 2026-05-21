import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wiki_pages.dart';
import '../models/wiki_page.dart';

final expandedCategoriesProvider = StateProvider<List<String>>(
  (ref) => ['Residential Life', 'Academics', 'Campus Life', 'Administration'],
);

final expandedSubcategoriesProvider = StateProvider<List<String>>(
  (ref) => [],
);

final wikiSearchQueryProvider = StateProvider<String>((ref) => '');

final wikiCategoryFilterProvider = StateProvider<String?>((ref) => null);

final wikiSearchResultsProvider =
    Provider<List<MapEntry<String, WikiPage>>>((ref) {
  final query = ref.watch(wikiSearchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return [];
  return kWikiPages.entries.where((e) {
    final p = e.value;
    return p.title.toLowerCase().contains(query) ||
        p.category.toLowerCase().contains(query) ||
        (p.subcategory?.toLowerCase().contains(query) ?? false);
  }).toList()
    ..sort((a, b) => a.value.title.compareTo(b.value.title));
});
