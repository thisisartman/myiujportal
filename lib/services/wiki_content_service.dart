import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads and parses wiki markdown files from the asset bundle.
class WikiContentService {
  const WikiContentService();

  /// Loads [assetPath] (e.g. 'wiki/01-Residential-Life/dorm-guide.md'),
  /// strips the YAML frontmatter block, and returns the body.
  Future<String> loadArticleBody(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return _stripFrontmatter(raw);
  }

  /// Strips the leading `---…---` frontmatter block if present.
  String _stripFrontmatter(String raw) {
    if (!raw.startsWith('---')) return raw.trim();
    final second = raw.indexOf('---', 3);
    if (second == -1) return raw.trim();
    return raw.substring(second + 3).trim();
  }
}

final wikiContentServiceProvider = Provider<WikiContentService>(
  (_) => const WikiContentService(),
);

/// FutureProvider that loads a single article body by asset path.
/// Key: the assetPath string (e.g. 'wiki/01-Residential-Life/dorm-guide.md').
final wikiArticleBodyProvider =
    FutureProvider.family<String, String>((ref, assetPath) async {
  final service = ref.read(wikiContentServiceProvider);
  return service.loadArticleBody(assetPath);
});
