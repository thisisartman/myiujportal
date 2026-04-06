# MyIUJ! Portal — UI/UX Revamp Design Spec
**Date:** 2026-04-07
**Status:** Approved

---

## Overview

Full visual and UX revamp of the MyIUJ! Portal Flutter web app. Transitions from an ad-hoc indigo/white theme to a cohesive flat design system appropriate for a university student portal. No functional changes — this is a pure design system implementation.

---

## 1. Design Style

**Flat Design** — 2D, minimalist, no drop shadows, no gradients. Clean lines, strong typographic hierarchy, purposeful use of color. Fast-loading, accessible, professional.

Reference: Linear.app + Notion applied to an academic context.

---

## 2. Color System

All colors defined as `const Color(...)` in a new `lib/theme/app_colors.dart`. No raw hex values in widget files.

| Token constant | Hex | Usage |
|---|---|---|
| `AppColors.primary` | `#0D9488` | Nav active, primary buttons, links, active chips |
| `AppColors.primaryLight` | `#CCFBF1` | Hover/selected backgrounds, chip fill |
| `AppColors.accent` | `#EA580C` | CTA buttons, alert badges, warning highlights |
| `AppColors.surface` | `#FFFFFF` | Cards, modals, input backgrounds |
| `AppColors.background` | `#F8FAFC` | Page/scaffold background |
| `AppColors.border` | `#E2E8F0` | Card borders, input borders, dividers |
| `AppColors.textPrimary` | `#0F172A` | Headings, primary labels |
| `AppColors.textSecondary` | `#64748B` | Subtitles, body descriptions |
| `AppColors.textMuted` | `#94A3B8` | Placeholders, timestamps, metadata |
| `AppColors.success` | `#16A34A` | Success toasts, on-time status chips |
| `AppColors.danger` | `#DC2626` | Error states, overdue status chips |
| `AppColors.sidebarBg` | `#0F172A` | Sidebar background (dark navy) |
| `AppColors.sidebarActive` | `#0D9488` | Sidebar active text + accent bar |
| `AppColors.sidebarInactive` | `#94A3B8` | Sidebar inactive item text |
| `AppColors.sidebarHover` | `#1E293B` | Sidebar item hover background |

---

## 3. Typography

**Font:** Plus Jakarta Sans (via `google_fonts` package, already a dependency)

Defined as a `TextTheme` in `lib/theme/app_theme.dart`.

| Style name | Size | Weight | Line height | Usage |
|---|---|---|---|---|
| `displayLarge` | 28px | 700 | 1.2 | Page titles |
| `headlineMedium` | 20px | 600 | 1.2 | Section headers, card titles |
| `titleMedium` | 15px | 600 | 1.3 | Widget headers, modal titles |
| `bodyMedium` | 14px | 400 | 1.5 | Body copy, list items |
| `bodySmall` | 13px | 400 | 1.5 | Secondary descriptions |
| `labelMedium` | 12px | 600 | 1.0 | Chips, badges, category labels |
| `labelSmall` | 11px | 600 | 1.0 | Timestamps, fine metadata |

---

## 4. Spacing & Shape

- **Base unit:** 4px. All spacing uses multiples of 4.
- **Page padding:** 24px horizontal, 24px vertical
- **Card gap (grid):** 16px
- **Section gap:** 24px
- **Inner card padding:** 20px
- **Border radius:** Cards and modals: 12px. Buttons: 8px. Chips: 20px (pill). Inputs: 8px.
- **No drop shadows** on any component. Separation achieved via `1px solid AppColors.border`.

---

## 5. Component Specifications

### 5.1 Sidebar

- Background: `AppColors.sidebarBg` (`#0F172A`)
- Width: 256px (unchanged)
- Institution name / logo text: white, 16px/700
- Divider: `Colors.white.withValues(alpha: 0.08)`

**Nav items (inactive):**
- Text: `AppColors.sidebarInactive`
- Icon: same
- Hover bg: `AppColors.sidebarHover`
- Border radius: 8px

**Nav items (active):**
- 3px left accent bar in `AppColors.sidebarActive`
- Text: `AppColors.sidebarActive`
- Background: `AppColors.sidebarActive.withValues(alpha: 0.15)`

### 5.2 Top Navigation

- Background: `AppColors.surface` (`#FFFFFF`)
- Bottom border: `1px solid AppColors.border`
- Height: 60px
- Search bar: pill shape (`border-radius: 24px`), background `#F1F5F9`
- User avatar: 36px circle, teal ring on hover (2px `AppColors.primary`)

### 5.3 Cards (dashboard widgets, facility cards, hub cards)

- Background: `AppColors.surface`
- Border: `1px solid AppColors.border`
- Border radius: 12px
- No shadow
- Hover state: border color → `AppColors.primary` (150ms transition via `AnimatedContainer`)
- Inner padding: 20px

### 5.4 Buttons

**Primary button:**
- Fill: `AppColors.primary`
- Text: white, 14px/600
- Height: 44px minimum
- Border radius: 8px
- Hover: `AppColors.primary` at 90% brightness

**Secondary button:**
- Fill: `AppColors.surface`
- Border: `1px solid AppColors.border`
- Text: `AppColors.textPrimary`, 14px/500

**Danger button:**
- Fill: `AppColors.danger`
- Text: white

**Disabled state:** 38% opacity (`withValues(alpha: 0.38)`) on all button types

### 5.5 Chips / Filter Tags

**Inactive:** bg `#F1F5F9`, text `#475569`, no border
**Active:** bg `AppColors.primaryLight`, text `AppColors.primary`, border `1px solid AppColors.primary`
**Border radius:** 20px (pill)
**Height:** 32px, padding: 12px horizontal

### 5.6 Input Fields

- Height: 44px (touch target compliant)
- Border: `1px solid AppColors.border`
- Border radius: 8px
- Focus border: `2px solid AppColors.primary`
- Background: `AppColors.surface`
- Label: 13px/500, `AppColors.textSecondary`, above field
- Placeholder: `AppColors.textMuted`

### 5.7 Modals (AppModal)

- Max-width: 448px (unchanged per PRD)
- Background: `AppColors.surface`
- Border radius: 16px
- Backdrop: `rgba(0,0,0,0.4)`
- Title: 18px/600, `AppColors.textPrimary`
- Close button: top-right, `AppColors.textMuted`

### 5.8 Toast Notifications

- Width: 320px max, slides in from bottom-right
- Border radius: 10px
- No shadow — left accent border 4px instead
- **Success:** bg `#F0FDF4`, border `AppColors.success`
- **Info/default:** bg `#F0FDFA`, border `AppColors.primary`
- **Error:** bg `#FEF2F2`, border `AppColors.danger`
- Auto-dismiss: 4s

### 5.9 Status Chips (On Time / Overdue / Severity)

- `On Time` / info: bg `AppColors.primaryLight`, text `AppColors.primary`
- `Overdue` / danger: bg `#FEE2E2`, text `AppColors.danger`
- `Warning`: bg `#FEF3C7`, text `#B45309`
- Border radius: 20px, padding: 4px 10px, 11px/600

---

## 6. Page-Specific Updates

### 6.1 Dashboard

- Background: `AppColors.background`
- Widget cards: updated borders/radius per spec above
- Alerts widget header icon: color → `AppColors.primary` (teal)
- Severity icon colors: use semantic `AppColors` tokens
- Quick links grid: teal icon backgrounds replacing indigo

### 6.2 Sidebar & Shell

- Sidebar fully restyled dark navy
- Active nav item uses teal left bar + teal text
- Mobile drawer uses same dark navy background

### 6.3 Facilities Hub

- Hub cards: updated to spec 5.3
- Feature icons: teal on light teal background

### 6.4 Calendar

- Selected date: `AppColors.primary` circle
- Event dots: type-based colors (class: blue, assignment: amber, event: teal)
- Month/year picker buttons: teal active state

### 6.5 Wiki

- Category accordion active: teal left border
- Breadcrumb link: `AppColors.primary`

---

## 7. UX Improvements

| Requirement | Implementation |
|---|---|
| Keyboard focus rings | All `InkWell`/`GestureDetector` replaced with `Focus` + visible `2px AppColors.primary` ring where applicable |
| Cursor pointer | `MouseRegion(cursor: SystemMouseCursors.click)` on all tappable elements (already partially done) |
| Hover states | `AnimatedContainer` with `150ms` duration on cards, nav items |
| Empty states | `_EmptyState` widget (icon + message) for loans list, search results, alerts |
| Touch targets | All buttons and interactive elements minimum 44px height |
| Consistent transitions | 150–200ms `Curves.easeOut` for all state transitions |

---

## 8. File Changes Summary

**New files:**
- `lib/theme/app_colors.dart` — `AppColors` class with all color constants
- `lib/theme/app_theme.dart` — `AppTheme.light()` returning full `ThemeData`

**Modified files:**
- `lib/app.dart` — use `AppTheme.light()` instead of inline `ThemeData`
- `lib/widgets/layout/sidebar.dart` — dark navy style, teal active state
- `lib/widgets/layout/top_nav.dart` — pill search bar, updated colors
- `lib/widgets/layout/app_shell.dart` — background color token
- `lib/widgets/dashboard/alerts_widget.dart` — token colors
- `lib/widgets/dashboard/quick_links_widget.dart` — teal icons
- `lib/widgets/dashboard/upcoming_events_widget.dart` — token colors
- `lib/widgets/dashboard/digital_id_widget.dart` — token colors
- `lib/widgets/common/app_modal.dart` — updated border radius, typography
- `lib/widgets/common/toast_overlay.dart` — new toast style with left accent border
- `lib/widgets/calendar/month_grid.dart` — teal selected date, updated event dots
- `lib/widgets/calendar/event_card.dart` — token colors
- `lib/pages/facilities_hub_page.dart` — updated card style
- `lib/pages/facilities/room_booking_page.dart` — token colors
- `lib/pages/facilities/library_page.dart` — token colors
- `lib/pages/facilities/campus_directory_page.dart` — token colors, filter chips
- `lib/widgets/facilities/booking_modal.dart` — token colors, step indicator
- `lib/widgets/facilities/booking_calendar.dart` — teal available day highlight
- `lib/widgets/facilities/booking_slot_selector.dart` — chip style update
- `lib/widgets/facilities/booking_form.dart` — input style update
- `lib/widgets/directory/directory_card.dart` — token colors, avatar style
- `lib/pages/wiki/wiki_home_page.dart` — token colors
- `lib/pages/wiki/wiki_article_page.dart` — token colors, breadcrumb
- `lib/widgets/wiki/breadcrumb_bar.dart` — teal link color
- `lib/pages/profile_page.dart` — token colors

**No deleted files.**
