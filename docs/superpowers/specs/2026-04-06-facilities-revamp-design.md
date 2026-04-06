# Facilities Hub Revamp — Design Spec
**Date:** 2026-04-06
**Status:** Approved

---

## Overview

The current `/facilities` page (a flat list of facility cards with a side booking panel) is replaced by a three-section hub. Each section is a sub-route of `/facilities`. The hub landing page presents three feature cards the user taps to navigate into.

---

## 1. Navigation & Routing

| Route | Widget | Notes |
|---|---|---|
| `/facilities` | `FacilitiesHubPage` | Hub with 3 feature cards |
| `/facilities/room-booking` | `RoomBookingPage` | Replaces current facilities page |
| `/facilities/library` | `LibraryPage` | New |
| `/facilities/directory` | `CampusDirectoryPage` | New |

The existing `FacilitiesPage` is deleted. The router adds the four routes above as child routes inside the `ShellRoute`.

The sidebar nav item "Facilities" continues to point to `/facilities`.

---

## 2. Room Booking (`/facilities/room-booking`)

### 2.1 Card List

Facilities are displayed in two named groups:

- **Classrooms & Lounges** — all facilities of category `classroom` or `lounge`
- **Gymnasium** — single card for the gymnasium facility

Each card shows: facility name + office authority chip. Tapping a card opens the booking modal.

### 2.2 Facility Model Change

`Facility` gains a `category` field:

```dart
enum FacilityCategory { classroom, lounge, gymnasium }
```

Mock data is updated to assign categories to existing and new facilities.

### 2.3 Booking Modal (Multi-step, maxWidth: 448)

A single `AppModal` hosts all three steps with a step indicator (1 / 2 / 3) at the top.

#### Step 1 — Calendar
- Displays the current month as a grid
- Days with ≥1 available slot: indigo highlight, tappable
- Days fully booked or in the past: grayed out, not tappable
- Tapping an available day advances to Step 2

#### Step 2 — Time Slot Selection
- Lists all time slots for the selected day as chips
- Available slots: tappable, turn indigo when selected (multi-select allowed)
- Unavailable slots: grayed out, disabled
- "Next" button enabled only when ≥1 slot is selected
- "Back" returns to Step 1

#### Step 3 — Booking Form
- "Back" returns to Step 2
Form fields vary by `FacilityCategory`:

| Category | Fields |
|---|---|
| `classroom` | Reason for booking |
| `lounge` / `gymnasium` | Reason for booking · Expected attendees · Setup requirements · Additional notes |

"Confirm & Submit" button:
1. Closes the modal
2. Shows toast: `"Your request has been submitted. You will be notified about the outcome shortly."`
3. Marks selected slots as unavailable in local session state
4. Adds a mock alert to the dashboard alerts feed: `"Your booking request for [Facility] on [Date] has been received. You will be notified shortly."`

"Cancel" / tapping outside closes the modal without saving state.

---

## 3. Library (`/facilities/library`)

A read-only information hub. No real backend; all data is mocked.

### 3.1 Sections

**My Loans**
- List of mock borrowed books
- Each entry: title, due date, status chip (On Time / Overdue)

**Library Resources**
- Cards for: Journals, Yearbooks, E-databases
- Each card: icon, title, brief description

**Search for Books**
- Prominent button: "Search MLIC Catalogue"
- Opens MLIC external search page in a new browser tab
- Copy below button: "Full catalogue integration coming soon."

### 3.2 Profile Page Link

The Profile page gets a "My Library" section that links to `/facilities/library`.

---

## 4. Campus Directory (`/facilities/directory`)

### 4.1 Layout

- **Search box** at top — filters results live as the user types
- **Filter chips** below the search box: All · Student · Faculty · Staff · Department · Organization
- **Result cards** below — filtered list

### 4.2 Result Cards

Each card shows: initials-based avatar, full name, type chip.

Tapping a card expands it in-place to reveal details:

| Type | Expanded Fields |
|---|---|
| Student | Name · Student ID · Email |
| Faculty / Staff | Name · Email · Office / Extension |
| Department | Name · Contact email · Phone extension |
| Organization | Name · Contact email · Coordinator name |

Privacy note: dorm room numbers are never displayed for students.

### 4.3 Organisations Section

Below the search results, a fixed "Organisations" section shows cards for:
- GSO (Graduate Student Organization)
- GSIM Student Council
- GSIR Student Council
- Student Clubs

Each org card has a "View Wiki page →" link that navigates to the corresponding wiki article.

### 4.4 Mock Data

`kMockDirectory` is extended with:
- Several mock student entries (name, student ID, email, type: `Student`)
- Org entries (GSO, councils, clubs) with coordinator info
- Existing faculty/department entries retain their current shape

---

## 5. State & Providers

| Provider | Purpose |
|---|---|
| `bookedSlotsProvider` | `Map<String, Set<String>>` — facilityId → set of booked slot times (session state) |
| `directorySearchProvider` | Search query string |
| `directoryFilterProvider` | Active filter chip value |
| `expandedDirectoryEntryProvider` | ID of the currently expanded directory card |

The booking modal manages its own step, selected date, and selected slots as local `StatefulWidget` state — these are ephemeral UI state that don't need to survive outside the modal lifecycle.

The existing `selectedFacilityProvider`, `selectedSlotProvider`, `bookingReasonProvider`, and `bookingStatusProvider` are removed.

---

## 6. File Changes Summary

**New files:**
- `lib/pages/facilities_hub_page.dart`
- `lib/pages/facilities/room_booking_page.dart`
- `lib/pages/facilities/library_page.dart`
- `lib/pages/facilities/campus_directory_page.dart`
- `lib/widgets/facilities/booking_modal.dart` (multi-step modal)
- `lib/widgets/facilities/booking_calendar.dart`
- `lib/widgets/facilities/booking_slot_selector.dart`
- `lib/widgets/facilities/booking_form.dart`
- `lib/widgets/directory/directory_card.dart`
- `lib/providers/directory_provider.dart`

**Modified files:**
- `lib/models/facility.dart` — add `FacilityCategory` enum + `category` field
- `lib/data/mock_data.dart` — update facilities, add library loans/resources, extend directory
- `lib/providers/facilities_provider.dart` — add new providers, remove old ones
- `lib/router/app_router.dart` — replace `/facilities` route with hub + 3 sub-routes
- `lib/widgets/layout/sidebar.dart` — Facilities nav item stays at `/facilities`
- `lib/pages/profile_page.dart` — add "My Library" link section

**Deleted files:**
- `lib/pages/facilities_page.dart`
- `lib/widgets/facilities/time_slot_selector.dart` (replaced by booking_slot_selector.dart)
