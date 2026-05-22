# MyIUJ! Portal — Changelog

---

## [2026-05-22] — Session 8: Palette Swap, Dark Mode & User Preferences

**Tracker items completed:** 7.1, 7.2, 7.3, 7.4

### Changed
- `lib/theme/app_colors.dart` — replaced entire `AppColors` class with IUJ blue palette (`primary #1A5296`, `primaryLight #EFF6FF`, new `accentBlue #2AAFCE` replacing old `tealInk`/`tealTint2`); added `AppColorsDark` class with navy-dark surface/background/text constants (7.1)
- `lib/theme/app_theme.dart` — added `AppTheme.dark()` mirroring `light()` structure but sourcing from `AppColorsDark`; both use Plus Jakarta Sans (7.1)
- `lib/app.dart` — added `darkTheme: AppTheme.dark()` and `themeMode` switch reading `themeProvider` (7.1)
- `lib/providers/calendar_provider.dart` — added `.agenda` to `CalendarViewMode` enum (7.3)
- `lib/providers/dashboard_provider.dart` — added `defaultCalendarView: CalendarViewMode` field (default `.month`) to `DashboardSettings`; added `setDefaultCalendarView()` to notifier (7.3)
- `lib/pages/calendar_page.dart` — `initState` now reads `dashboardSettingsProvider.defaultCalendarView` and applies it to `calendarViewModeProvider` before the filter override (7.3)
- `lib/pages/profile_page.dart` — Settings tab: Calendar section now correctly maps `Month`/`Week`/`Agenda` buttons to `CalendarViewMode.month`/`.week`/`.agenda` (was incorrectly using `.week` labeled 'Agenda') (7.4)

### Added
- `lib/providers/theme_provider.dart` — `AppThemeMode` enum (system/light/dark) + `ThemeNotifier` (`Notifier<AppThemeMode>`) + `themeProvider` (7.1)
- `lib/providers/notification_prefs_provider.dart` — `NotificationPrefs` model (`bookingAlerts`, `announcementAlerts`, `calendarReminders`, all default true) + `NotificationPrefsNotifier` + `notificationPrefsProvider` (7.2)

### Notes
- All `tealInk` and `tealTint2` references were already replaced by prior session work (confirmed by grep — zero remaining); color values updated in `app_colors.dart`
- `alerts_widget.dart` and `today_timeline_card.dart` notification filtering was already in place from prior session work
- Phase 1 dark mode: Material widgets adapt via `ThemeData`; custom widgets using static `AppColors.xxx` still render light values — Phase 2 widget-level migration is a future iteration

---

## [2026-05-22 02:36] — Session 7: Calendar Group 5 — Items 5.7–5.11 (Full Group 5 Complete)

**Tracker items completed:** 5.7, 5.8, 5.9, 5.10, 5.11

### Changed
- `lib/pages/calendar_page.dart` — divider text in Add Event modal changed from `'or'` to `'— OR —'` (5.7)
- `lib/providers/meeting_provider.dart` — added `totalInvitees: int` field to `MeetingData`; pre-seeded `MeetingNotifier.build()` with a mock `SD1SYNC` meeting (creatorId ≠ current user) so receiver view is demo-able without creating a meeting (5.11)
- `lib/models/calendar_event.dart` — added nullable `meetingCode: String?` field; backward-compatible (all existing events default to null) (5.11)
- `lib/widgets/calendar/group_meeting_modal.dart` — full overhaul: Step 1 adds `_viewMonth` state with prev/next month nav and correct disabled-day logic (5.8); Step 2 replaces center `Text` with editable `TextField` for direct minute entry, `+/-` buttons sync the controller, duration label updated to `'1 hr 10 min'` format (5.9); Step 3 replaces `SegmentedButton` with `SwitchListTile` for simple on/off weekly toggle (5.10); Step 4 summary wrapped in styled card; `_next()` now creates `MeetingData` using `kMockStudentInfo.studentId` as creatorId, adds a `CalendarEvent` with `meetingCode`, pops modal, and routes to `/meeting/<code>` (5.11)
- `lib/widgets/calendar/event_card.dart` — converted to `ConsumerWidget`; detects `event.meetingCode != null`; creator (matching `kMockStudentInfo.studentId`) sees pending count subtitle and opens `MeetingCreatorModal` on tap; receiver navigates to `/meeting/<meetingCode>` on tap (5.11)
- `lib/pages/meeting_page.dart` — full rewrite as `ConsumerStatefulWidget`; receiver view renders `MonthGrid` as background and auto-opens `AppModal` with `_ReceiverPanel` (selectable `FilterChip` slots, submit → toast → back to `/calendar`); creator view shows share link box, responded count pill, and "View responses" button opening `MeetingCreatorModal` (5.11)

### Added
- `lib/widgets/calendar/meeting_creator_modal.dart` — new `ConsumerStatefulWidget`; shows responded count badge, slot list with `RadioGroup`/`RadioListTile` selection, `CircleAvatar` respondent icons per slot, and "Confirm meeting" button that calls `confirmMeeting()` and shows success toast (5.11)

### Notes
- 5.7 pre-conditions (date auto-populate, course dropdown, button rename) were already implemented in Session 6; only the divider text update shipped this session.
- `RadioListTile.groupValue`/`onChanged` deprecated in Flutter 3.32+; replaced with `RadioGroup` ancestor widget.
- `SwitchListTile.activeColor` deprecated in Flutter 3.31+; replaced with `activeThumbColor`.
- Demo receiver flow: navigate to `/meeting/SD1SYNC` (pre-seeded) — calendar grid appears in background, invite modal auto-opens. Demo creator flow: create a meeting via "Schedule group meeting" → code generated → creator view on `/meeting/<code>`, or find the event in the calendar event list and click to open `MeetingCreatorModal`.

---

## [2026-05-22 02:08] — Session 6: Calendar Group 5 — Items 5.1–5.6

**Tracker items completed:** 5.1, 5.2, 5.3, 5.4, 5.5, 5.6

### Changed
- `lib/pages/calendar_page.dart` — replaced hardcoded `'Spring 2026 · Week 6'` with `_semesterLabel()` which computes semester and week number dynamically from `DateTime.now()` (5.2); converted `_CalendarToolbar` from `StatelessWidget` to `ConsumerWidget` so it can watch `displayedMonthProvider` directly; added year `DropdownButton` to toolbar constrained to `kAdmissionYear`–`kGraduationYear` range (5.4)
- `lib/widgets/calendar/event_card.dart` — removed `go_router` and `dashboard_event_utils` imports; replaced tappable `_Chip` class with static `_StaticChip` (no `GestureDetector`/`MouseRegion`) so chip taps propagate to the parent card GestureDetector, ensuring all interaction goes through `EventDetailModal` (5.5)
- `lib/widgets/calendar/event_detail_modal.dart` — imported `dashboard_event_utils.dart`; fixed chip routing: course → `courseWikiRoute(normalized)`, location → `roomWikiRoute(part)`, professor → `/facilities/directory?query=<encoded>` (was missing query param and using wrong route for location/course) (5.6)

### Added
- `lib/data/mock_data.dart` — `kAdmissionYear = 2025` and `kGraduationYear = 2027` constants derived from `kMockStudentInfo.cohort` ('Class of 2027', 2-year MBA program) (5.4)

### Notes
- **5.1 (filter chips inside card):** Confirmed by code audit — chips were already inside `_eventPanel`'s `PageCard.child` in the current implementation. No layout change was needed; marked complete.
- **5.3 (month grid hover):** Confirmed by code audit — `_DayCellState` in `month_grid.dart` already had `MouseRegion`, `_hovering` bool, and `AppColors.primaryLight` background on hover. No change needed; marked complete.
- Items 5.7–5.11 (Add Event enhancements, Group Meeting overhaul, Meeting URL flow) remain for the next session.

---

## [2026-05-21 14:38] — Session 5: Dashboard Deep-Linking — Full Group 2 Completion

**Tracker items completed:** 2.1, 2.2, 2.3, 2.4, 2.5

### Changed
- `lib/widgets/dashboard/today_timeline_card.dart` — professor chip now routes to `/facilities/directory?query=<encoded-name>` (removed directorySearchProvider state writes); room chip routes to wiki via `roomWikiRoute`; type chip gains `onTap` and routes to `/calendar?filter=<type.name>`; removed unused `directory_provider` import
- `lib/widgets/dashboard/upcoming_events_widget.dart` — `_EventRow` simplified to `StatelessWidget` (no longer needs `ref`); professor chips route to directory with `?query=` param; room chips route to wiki; tag chips route to `/calendar?filter=`; type label chip includes filter param; imports `dashboard_event_utils.dart`
- `lib/widgets/calendar/event_card.dart` — replaced plain `Text(e.detail)` with a parsed `Wrap` of tappable chips using identical classification logic (course code / professor / facility / tag), each routed to the correct destination; imports `go_router` and `dashboard_event_utils.dart`
- `lib/pages/calendar_page.dart` — converted from `ConsumerWidget` to `ConsumerStatefulWidget`; accepts `initialFilter` param; `initState` applies filter via post-frame callback so the chip is pre-selected on deep-link arrival
- `lib/router/app_router.dart` — `/calendar` route extracts `filter` query param and passes it to `CalendarPage`; `/facilities/directory` route extracts `query` param and passes it to `CampusDirectoryPage`
- `lib/pages/facilities/campus_directory_page.dart` — accepts `initialQuery` param; `initState` pre-populates the text field and fires `_launch` via post-frame callback when a query arrives from a deep-link

### Added
- `lib/widgets/dashboard/dashboard_event_utils.dart` — `courseWikiRoute(code)` and `roomWikiRoute(room)` helpers; room logic maps Library/MLIC to the library-overview wiki article, all other rooms to the facilities-campus wiki article

### Notes
- Room wiki routing is a best-effort mapping — classrooms like G.11 and P.101 route to the facilities-campus article since no individual room wiki pages exist yet.
- `_EventRow` in `upcoming_events_widget.dart` no longer needs Riverpod; the tag routing now uses the URL-param approach instead of writing directly to `calendarFilterProvider`.
- Group 5 (Calendar) is the only remaining group — 11 items, estimated 2 sessions.

---

## [2026-05-21 14:20] — Session 4: Profile Tabs Part B — Full Group 3 Completion

**Tracker items completed:** 3.3, 3.4, 3.5, 3.6, 3.8, 3.9, 3.10

### Changed
- `lib/pages/profile_page.dart` — expanded tab bar from 3 to 5 tabs (Personal Info, Academic, Financial, My Library, Settings); tab bar is now scrollable with `tabAlignment: start`
- `lib/pages/profile_page.dart` — Academic tab: Program field now renders as mixed-widget row with tappable GSIM and MBA chips routing to their respective wiki pages; "Adviser" renamed to "Mentor"; Research Supervisor field added below; both professor names are tappable chips routing to GSIM faculty wiki page
- `lib/pages/profile_page.dart` — added AnimatedSwitcher (150 ms crossFade) around tab content so switching tabs fades smoothly
- `lib/pages/profile_page.dart` — Sign Out button now shows AppModal confirmation ("Sign out?" / body text / Cancel left + Confirm right in danger color) before logging out
- `lib/pages/profile_page.dart` — issue report toast message updated to "Report submitted. The relevant office has been notified."
- `lib/pages/dashboard_page.dart` — removed `_DashboardControls` and `_ControlPill` classes entirely; `_GreetingSection` simplified to a plain `StatelessWidget` returning only the greeting text
- `lib/widgets/profile/issue_report_modal.dart` — replaced all three `DropdownButtonFormField` with `DropdownMenu` + `alignment: AlignmentDirectional.bottomStart` to force downward opening; added step 4 comments `TextField`; progress bar now spans 4 steps; bottom button reads "Skip" when field is empty and "Next" once user starts typing; step 4 submission pops `true`

### Added
- `lib/pages/profile_page.dart` — My Library tab: "My Active Loans" section with inline "Go to My Library →" button routing to `/facilities/library`; "My Loan History" section below it; both sections use a shared `_LibraryLoanRow` widget with left-border color coding (teal/amber/red) and status labels
- `lib/pages/profile_page.dart` — Settings tab: vertical layout with SegmentedButton controls for column count and quick link style, plus `SwitchListTile` toggles for all 7 widget visibility flags — all read/write `dashboardSettingsProvider`
- `lib/data/mock_data.dart` — `kMockLibraryLoanHistory` with 3 past loan records (same record type as `kMockLibraryLoans`)

### Notes
- Settings tab uses `SwitchListTile` instead of a popup menu for visibility toggles — better affordance in a dedicated settings context.
- Loan history rows reuse the same color/status logic as active loans but always show "RETURNED" as the status label; left-border color reflects whether the return was on-time (teal) or late (red).
- Groups 2 (Dashboard deep-linking) and 5 (Calendar) remain fully pending.

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
