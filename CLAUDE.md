# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MyIUJ!** is a campus portal for the International University of Japan (IUJ).

- **Reference prototype:** `MyIUJ! Revamp.jsx` (kept, not deleted — source of truth for UI/UX)
- **Current implementation:** Flutter web app under `lib/`
- **Target platforms:** Web (now), Android/iOS (future via same codebase)

## Tech Stack

- **Flutter 3.41.4 / Dart 3.11.1**
- **flutter_riverpod ^2.6.1** — state management
- **go_router ^14.x** — URL-based routing (web-friendly deep links)
- **google_fonts ^6.x** — Inter typeface
- **intl ^0.19** — date formatting

## Key Commands

```bash
# Run in browser (development)
flutter run -d chrome

# Production build
flutter build web --release

# Analyze code
dart analyze lib/
```

## Project Structure

```
lib/
├── main.dart                        # ProviderScope + runApp
├── app.dart                         # MaterialApp.router, theme, GoRouter instance
├── router/app_router.dart           # GoRouter routes (ShellRoute wraps all pages)
├── models/
│   ├── alert_item.dart              # AlertSeverity enum + AlertItem class
│   ├── calendar_event.dart          # CalendarEvent, CalendarEventType enum + extensions
│   ├── facility.dart                # Facility, TimeSlot
│   └── wiki_page.dart               # WikiPage, WikiCategory, DirectoryEntry
├── data/mock_data.dart              # All hardcoded mock data (ported from JSX prototype)
├── providers/
│   ├── calendar_provider.dart       # events, selectedDate, filter, viewMode
│   ├── sidebar_provider.dart        # mobile open / desktop collapsed
│   ├── wiki_provider.dart           # expandedCategories, search query/results
│   └── facilities_provider.dart     # selectedFacility, selectedSlot, booking state
├── pages/
│   ├── dashboard_page.dart          # Route: /
│   ├── calendar_page.dart           # Route: /calendar
│   ├── facilities_page.dart         # Route: /facilities
│   └── wiki/
│       ├── wiki_home_page.dart      # Route: /wiki
│       └── wiki_article_page.dart   # Route: /wiki/:articleId  (handles all wiki sub-pages)
└── widgets/
    ├── layout/
    │   ├── app_shell.dart           # ShellRoute wrapper — persistent sidebar + top nav
    │   ├── sidebar.dart             # Collapsible sidebar with wiki accordion
    │   └── top_nav.dart             # Hamburger, search bar, user avatar
    ├── dashboard/
    │   ├── upcoming_events_widget.dart  # Upcoming events list with tag chips
    │   ├── quick_links_widget.dart      # 2×2 grid of navigation shortcuts
    │   ├── alerts_widget.dart           # Expandable IUJ news/alerts feed
    │   └── digital_id_widget.dart       # Student ID card linking to profile
    ├── calendar/
    │   ├── month_grid.dart          # Dynamic month grid with event dot indicators
    │   └── event_card.dart          # Hover edit/delete; edit modal
    ├── facilities/
    │   ├── facility_card.dart       # Selectable facility tile
    │   └── time_slot_selector.dart  # Available/unavailable slot list
    ├── wiki/
    │   └── breadcrumb_bar.dart      # "Back to [Parent]" navigation
    └── common/
        ├── app_modal.dart           # Reusable modal, maxWidth: 448 (≈ Tailwind max-w-md)
        └── toast_overlay.dart       # Transient toast notifications
```

## Routing

| Path | Widget | Notes |
|------|--------|-------|
| `/` | `DashboardPage` | |
| `/calendar` | `CalendarPage` | |
| `/facilities` | `FacilitiesPage` | |
| `/wiki` | `WikiHomePage` | |
| `/wiki/:articleId` | `WikiArticlePage` | handles category-, subcategory-, article- pages |
| `/wiki/:category/:articleId` | `WikiArticlePage` | URL-composed articleId |

## Key Design Constraints (from PRD)

- All modals: `maxWidth: 448` (equivalent to Tailwind `max-w-md`)
- Calendar event types: strictly **"Classes"**, **"Assignments"**, **"Events"** (enum `CalendarEventType`)
- Device calendar sync copy: use generic **"device calendar"** — never brand-specific names
- Dashboard `DashboardCalendarWidget`: date number on top, day-of-week below; **no location**; entire widget taps to `/calendar`
- Wiki RBAC: Students can only "Suggest Edit"; only Professors/OAA staff can publish new courses
- Wiki moderation: student submissions show "Submitted for Moderation" state — not live publish

## Reference File

`MyIUJ! Revamp.jsx` is the original single-file React prototype. It is kept as a design reference.
All mock data, wiki content, and UI patterns should match it.
