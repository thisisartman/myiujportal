import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';

final expandedCategoriesProvider = StateProvider<List<String>>(
  (ref) => kWikiCategories.map((c) => c.name).toList(),
);

final expandedSubcategoriesProvider = StateProvider<List<String>>(
  (ref) => ['Finance', 'General Management', 'IT & Operations'],
);

final wikiSearchQueryProvider = StateProvider<String>((ref) => '');

final wikiSearchResultsProvider = Provider<List<MapEntry<String, dynamic>>>((ref) {
  final query = ref.watch(wikiSearchQueryProvider);
  if (query.isEmpty) return [];
  return kWikiPages.entries.where((entry) {
    final page = entry.value;
    return !page.isLandingPage &&
        (page.title.toLowerCase().contains(query.toLowerCase()) ||
            page.category.toLowerCase().contains(query.toLowerCase()));
  }).toList();
});
