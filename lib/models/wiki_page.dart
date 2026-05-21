class WikiPage {
  final String id;
  final String title;
  final String category;
  final String? subcategory;
  final bool isLandingPage;
  final String? parentPage;
  final String lastUpdated;
  final String? summary;
  final String? assetPath;   // e.g. 'wiki/01-Residential-Life/dorm-guide.md'
  final String ownerRole;    // 'admin' | 'faculty-gsim' | 'faculty-gsir' | 'faculty' | 'library-staff' | 'student-body'
  final List<String> editRoles;
  final List<String> suggestRoles;

  const WikiPage({
    required this.id,
    required this.title,
    required this.category,
    this.subcategory,
    this.isLandingPage = false,
    this.parentPage,
    required this.lastUpdated,
    this.summary,
    this.assetPath,
    this.ownerRole = 'admin',
    this.editRoles = const ['admin'],
    this.suggestRoles = const ['student'],
  });

  /// Whether a given role string can publish edits directly.
  bool canEdit(String role) => editRoles.contains(role);

  /// Whether a given role string can suggest (moderated) edits.
  bool canSuggest(String role) => suggestRoles.contains(role) && !canEdit(role);
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
  final String? studentId;
  final String? coordinator;

  const DirectoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
    required this.phone,
    this.studentId,
    this.coordinator,
  });
}
