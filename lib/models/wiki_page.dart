class WikiPage {
  final String id;
  final String title;
  final String category;
  final String? subcategory;
  final bool isLandingPage;
  final String? parentPage;
  final String lastUpdated;

  const WikiPage({
    required this.id,
    required this.title,
    required this.category,
    this.subcategory,
    this.isLandingPage = false,
    this.parentPage,
    required this.lastUpdated,
  });
}

class WikiCategory {
  final String id;
  final String name;
  final List<WikiSubcategory> subcategories;

  const WikiCategory({
    required this.id,
    required this.name,
    this.subcategories = const [],
  });
}

class WikiSubcategory {
  final String id;
  final String name;

  const WikiSubcategory({required this.id, required this.name});
}

class DirectoryEntry {
  final int id;
  final String name;
  final String type;
  final String email;
  final String phone;

  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
    required this.phone,
  });
}
