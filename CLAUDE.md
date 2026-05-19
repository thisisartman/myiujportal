# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MyIUJ!** is a campus portal for the International University of Japan (IUJ).

- **Reference prototype:** `MyIUJ! Revamp.jsx` — kept as UI/UX source of truth; all mock data, wiki content, and visual patterns must match it
- **Current implementation:** Flutter web app under `lib/`
- **Target platforms:** Web (primary), Android/iOS (future via same codebase)

## Key Commands

```bash
# Run in browser (development)
flutter run -d chrome

# Production build
flutter build web --release

# Analyze (lint)
flutter analyze lib/

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Tech Stack

- **Flutter 3.41.4 / Dart 3.11.1**
- **flutter_riverpod ^2.6.1** — all state via `StateNotifierProvider` / `Provider`
- **go_router ^14.x** — URL routing; `routerProvider` in `router/app_router.dart`
- **google_fonts ^6.x** — Inter typeface via `AppTheme.light()` in `theme/app_theme.dart`
- **intl ^0.19** — date formatting
- **url_launcher ^6.x** — external links

## Architecture

### Auth & Routing

Auth is a single `bool` in `authProvider` (`StateNotifierProvider<AuthNotifier, bool>`). The router (`routerProvider`) guards all shell routes: unauthenticated users are redirected to `/login`; the bridge is `_AuthListenable extends ChangeNotifier` in `router/app_router.dart`.

Demo credentials (swap when real auth arrives):
- `student@iuj.ac.jp` / `iuj2026`
- `professor@iuj.ac.jp` / `iuj2026`
- `admin@iuj.ac.jp` / `iuj2026`

All authenticated pages live inside a `ShellRoute` that renders `AppShell` (persistent sidebar + top nav). `/login` is a bare `GoRoute` outside the shell.

### Route table

| Path | Widget |
|------|--------|
| `/login` | `LoginPage` |
| `/` | `DashboardPage` |
| `/calendar` | `CalendarPage` |
| `/facilities` | `FacilitiesHubPage` |
| `/facilities/room-booking` | `RoomBookingPage` |
| `/facilities/library` | `LibraryPage` |
| `/facilities/directory` | `CampusDirectoryPage` |
| `/wiki` | `WikiHomePage` |
| `/wiki/:articleId` | `WikiArticlePage(articleId)` |
| `/wiki/:category/:articleId` | `WikiArticlePage(articleId: "$category-$articleId")` |
| `/profile` | `ProfilePage` |
| `/meeting/:code` | `MeetingPage(code)` |

### State (Providers)

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | `StateNotifierProvider<AuthNotifier, bool>` | Login/logout |
| `calendarProvider` | — | Events, selectedDate, filter, viewMode |
| `sidebarProvider` | — | Mobile open / desktop collapsed |
| `wikiProvider` | — | expandedCategories, search query/results |
| `facilitiesProvider` | — | selectedFacility, selectedSlot, booking state |
| `alertsProvider` | — | IUJ news/alerts feed |
| `directoryProvider` / `directoryFilterProvider` | — | Campus directory & filter state |
| `dashboardProvider` | — | Dashboard aggregation |
| `meetingProvider` | — | Group meeting/poll state |

### Theme

Colors live in `theme/app_colors.dart` as `AppColors` static constants (never hardcode hex values). Theme wiring is in `theme/app_theme.dart`. Brand: teal primary `#0D9488`, orange accent `#EA580C`, dark-navy sidebar `#0F172A`.

### Common Widgets

- `AppModal` — all modals must use this; **`maxWidth: 448`** (Tailwind `max-w-md` equivalent)
- `ToastOverlay` — transient notifications
- `DashboardCard` — standard card surface for dashboard sections
- `HoverCard` — card with hover elevation/highlight
- `PageChrome` — consistent page-level padding/header wrapper

## Project Structure

```
lib/
├── main.dart                    # ProviderScope + runApp
├── app.dart                     # MaterialApp.router → routerProvider + AppTheme
├── router/app_router.dart       # All GoRouter routes; _AuthListenable bridge
├── theme/
│   ├── app_colors.dart          # All color constants (AppColors)
│   └── app_theme.dart           # ThemeData via AppTheme.light()
├── models/                      # Plain Dart data classes + enums
├── data/mock_data.dart          # All hardcoded mock data (matches JSX prototype)
├── providers/                   # One file per feature domain
├── pages/
│   ├── login_page.dart
│   ├── dashboard_page.dart
│   ├── calendar_page.dart
│   ├── facilities_hub_page.dart # Hub landing; links to sub-pages
│   ├── facilities/
│   │   ├── room_booking_page.dart
│   │   ├── library_page.dart
│   │   └── campus_directory_page.dart
│   ├── profile_page.dart
│   ├── meeting_page.dart
│   └── wiki/
│       ├── wiki_home_page.dart
│       └── wiki_article_page.dart
└── widgets/
    ├── layout/                  # app_shell, sidebar, top_nav
    ├── common/                  # app_modal, toast_overlay, dashboard_card, hover_card, page_chrome
    ├── dashboard/               # up_next_card, today_timeline_card, upcoming_events_widget,
    │                            # quick_links_widget, alerts_widget, digital_id_widget,
    │                            # group_meeting_polls_card, library_loans_card, profile_dropdown
    ├── calendar/                # month_grid, event_card, event_detail_modal, group_meeting_modal
    ├── facilities/              # expandable_room_card, booking_calendar, booking_slot_selector,
    │                            # booking_form, booking_modal
    ├── directory/               # directory_card
    ├── profile/                 # digital_id_card, issue_report_modal
    └── wiki/                    # breadcrumb_bar
```

## Key Design Constraints (from PRD)

- **All modals:** `maxWidth: 448` via `AppModal`
- **Calendar event types:** strictly `CalendarEventType.classes`, `.assignments`, `.events` — no other values
- **Device calendar sync copy:** always "device calendar" — never brand names (Samsung, Apple, Google)
- **Dashboard calendar widget:** date number on top, day-of-week below; no location; whole widget navigates to `/calendar`
- **Wiki RBAC:** Students → "Suggest Edit" only; Professors/OAA staff → publish new courses. Student submissions must show "Submitted for Moderation" state, not go live immediately
- **Colors:** always use `AppColors` constants — never inline hex
- **No page transitions:** all routes use `NoTransitionPage`
