# MyIUJ! Portal — Changelog

---

## [2026-05-20 ~evening] — Sessions 1–3: Global Interactions, Wiki, Facilities, Profile Layout

**Tracker items completed:** 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.7, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 6.1, 6.2, 6.3, 6.4, 6.5

### Changed
- `app_shell.dart` — wrapped content in `SelectionArea` to enable text selection globally
- All widget files — audited `InkWell`/`GestureDetector` for consistent hover/touch behavior
- `sidebar.dart`, `top_nav.dart` — MyIUJ logo now clickable, routes to Dashboard
- `sidebar.dart` — removed standalone Sign Out button (now lives only in profile dropdown)
- `profile_page.dart` — restructured to 2-column desktop layout; ID card on left, content on right
- `profile_page.dart` — moved Report Issues and Sign Out buttons to below the ID card
- `widgets/profile/digital_id_card.dart` — student name moved inside card; Code128 linear barcode added encoding student ID
- `wiki_home_page.dart`, `wiki_provider.dart` — search bar now persistent; does not unmount on results state
- `wiki_home_page.dart` — filter chips replaced with real category filters (Residential Life, Academics, Campus Life, Administration)
- `wiki_home_page.dart` — Explore Categories boxes resized and arranged in a single row with Quick Links-style hover effect
- `facilities_hub_page.dart` — full card hover effect on all facility cards
- `room_booking_page.dart`, `expandable_room_card.dart` — room list replaced with 3-column GridView with mobile-shortened names
- `widgets/facilities/booking_calendar.dart` — 3-state date coloring implemented (green/yellow/gray)
- `pages/facilities/library_page.dart` — replaced body with redirect to official MLIC site
- `pages/facilities/campus_directory_page.dart` — search now deep-links to official IUJ directory

### Added
- `wiki_home_page.dart` — "Featured / Popular Articles" section below categories
- `wiki_home_page.dart` — "Popular / Recommended" section with 5–6 curated article links
- `wiki_article_page.dart` — "Book this space →" button on room/location article pages

### Notes
- Sessions 1–3 completed 2026-05-20. Changelog written retrospectively on 2026-05-21 as git and changelog tooling was not yet in place during those sessions.
- Git initialized and auto-commit hook configured on 2026-05-21 — all future sessions tracked automatically.
- Remaining: Sessions 4–7 covering Profile tabs (3b), Dashboard deep-linking (Group 2), Calendar (Group 5).
