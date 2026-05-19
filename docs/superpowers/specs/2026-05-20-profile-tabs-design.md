# Profile Page Tab Layout Redesign

**Date:** 2026-05-20
**Status:** Approved

---

## Overview

Replace the existing static, non-functional profile tabs with a working three-tab layout using Flutter's `DefaultTabController`. Dissolve the `_AdminVault` widget, distributing its content across the appropriate tabs. Add a persistent Report Issues entry point both at the bottom of every tab and as an icon in the top nav bar.

---

## Tab Structure

`DigitalIdCard` remains pinned above the `TabBar` — it is identity-level content, not tab-specific.

Below it: a `TabBar` with three tabs, followed by a `TabBarView` rendering each tab's content.

```
ProfilePage
├── PageGreeting
├── DigitalIdCard          ← always visible, above tabs
├── TabBar [Personal Info | Academic | Financial]
└── TabBarView
    ├── Personal Info tab
    ├── Academic tab
    └── Financial tab
```

---

## Content Per Tab

### Personal Info
Single info card with rows: Name, Email, Campus Address, Student ID. All mock data.

### Academic
- Info card: Program, Year, Status, Adviser
- My Library tile → navigates to `/facilities/library`
- Records Changelog inline list (existing `_ChangelogRow` items, no modal)

### Financial
Expandable list of monthly statement items. Each row:
- **Collapsed:** month label (e.g. "April 2026 Statement")
- **Expanded:** Open button + Download button (both show AppModal placeholder — "Coming soon")

Mock data: 5–6 entries in `mock_data.dart`.

---

## Persistent Report Issues

- **Bottom of every tab:** `OutlinedButton.icon` with danger styling, calls `IssueReportModal` via `AppModal`. Shown below the tab content regardless of which tab is active.
- **Top nav bar:** `IconButton` using `Icons.warning_amber_rounded`, colored amber/orange (`AppColors.warning`), placed next to the existing profile avatar button in `top_nav.dart`. Calls the same `IssueReportModal` flow.

---

## Architecture

### Files changed
| File | Change |
|------|--------|
| `lib/pages/profile_page.dart` | Full rewrite — replace static tabs with `DefaultTabController` + `TabBar` + `TabBarView`; delete `_AdminVault`, `_ProfileTabs`, `_ProfileTab`; add persistent Report Issues button |
| `lib/widgets/layout/top_nav.dart` | Add warning icon button before profile avatar |
| `lib/data/mock_data.dart` | Add mock financial statement list (5–6 months) |

### No new files required.

### Deleted widgets
- `_AdminVault`
- `_ProfileTabs`
- `_ProfileTab`
- `_VaultTile`

### Retained widgets
- `_infoCard` — reused in Personal Info and Academic tabs
- `_ChangelogRow` — reused inline in Academic tab
- `DigitalIdCard` — stays above tabs

---

## Layout Behaviour

The existing wide/narrow two-column split is removed. `DigitalIdCard` spans full width above the `TabBar`. `TabBarView` content is always single-column — cleaner with tab-based navigation. The sign out button moves to the bottom of the **Personal Info** tab (below the info card), right-aligned, retaining its current danger styling.

---

## Constraints

- All colors via `AppColors` constants — no inline hex
- Report Issues uses existing `IssueReportModal` + `AppModal` (maxWidth: 448)
- No new data requirements on IUJ's end — financial statement rows are mock only
- No page transitions (existing project constraint)
