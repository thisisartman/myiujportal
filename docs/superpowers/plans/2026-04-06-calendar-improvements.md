# Calendar Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the calendar page with: (1) year/month picker on header click, (2) always-visible inline edit/delete buttons on event cards without layout shift, (3) "Add Event" button moved above the events list, (4) Group Meeting option in the Add Event modal.

**Architecture:** `MonthGrid` gets a new `onMonthTap`/`onYearTap` callback that triggers custom picker overlays (built as reusable modal sheets). `EventCard` is restructured so the type-tag row always shows the action buttons right-aligned — hover only controls opacity, not presence. The Group Meeting flow opens a second modal with a date/slot selection grid and generates a mock shareable link.

**Tech Stack:** Flutter 3.41.4, flutter_riverpod ^2.6.1

---

## File Map

| Action | File | Change |
|--------|------|--------|
| Modify | `lib/widgets/calendar/month_grid.dart` | Add tappable month/year header with picker |
| Modify | `lib/widgets/calendar/event_card.dart` | Always-visible inline buttons; no layout shift |
| Modify | `lib/pages/calendar_page.dart` | Move Add Event button above events list |
| Create | `lib/widgets/calendar/group_meeting_modal.dart` | Slot-selection + mock link generation |

---

## Task 1: Event card — inline always-visible action buttons

**Problem:** Edit and Delete buttons currently appear/disappear on hover, causing the card to resize. The spec wants buttons always present in the same row as type-tag and time, right-aligned. On hover they become fully opaque; at rest they are faint but present.

**Files:**
- Modify: `lib/widgets/calendar/event_card.dart`

- [ ] **Step 1: Restructure the card layout**

Replace the full `_EventCardState.build` method:

```dart
@override
Widget build(BuildContext context) {
  final e = widget.event;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovering = true),
    onExit: (_) => setState(() => _hovering = false),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: e.type.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: e.type.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: e.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW: type tag + time + action buttons (always visible)
                Row(
                  children: [
                    // Type tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: e.type.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e.type.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: e.type.color),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(e.time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    const Spacer(),
                    // Action buttons — always present, animate opacity on hover
                    AnimatedOpacity(
                      opacity: _hovering ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28, height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              color: const Color(0xFF6B7280),
                              onPressed: () => _showEditModal(context, e),
                            ),
                          ),
                          SizedBox(
                            width: 28, height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_outline, size: 14),
                              color: const Color(0xFFEF4444),
                              onPressed: () => ref.read(calendarEventsProvider.notifier).deleteEvent(e.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                Text(e.detail, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/widgets/calendar/event_card.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/calendar/event_card.dart
git commit -m "fix: event card buttons always visible inline, no layout shift on hover"
```

---

## Task 2: Move "Add Event" button above the events list

**Problem:** "Add Event" is currently in the top-right of the page header. The spec wants it right-aligned directly above the events cards panel.

**Files:**
- Modify: `lib/pages/calendar_page.dart`

- [ ] **Step 1: Read the current events panel section**

The relevant section is around line 80–130 in `calendar_page.dart`. The right column of the wide layout shows the events list. It looks like:

```dart
Expanded(
  flex: 2,
  child: _eventsList(filteredEvents, selectedDate, ref, context),
),
```

And `_eventsList` is a separate method. Read lines 80–160 of `calendar_page.dart` to confirm the exact structure before editing.

- [ ] **Step 2: Remove Add Event button from page header**

In the page header `Row` (lines ~24–44), remove the `ElevatedButton.icon` for Add Event entirely:

```dart
// BEFORE
Row(
  children: [
    const Column( ... ), // Calendar title
    const Spacer(),
    ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Event'),
      ...
      onPressed: () => _showAddEventModal(context, ref),
    ),
  ],
),

// AFTER
Row(
  children: [
    const Column( ... ), // Calendar title — unchanged
  ],
),
```

- [ ] **Step 3: Add Add Event button at top of events list**

Find the `_eventsList` method (or wherever the events column is built) and add the button as the first widget above the list:

```dart
// At the top of the events panel column, before the event cards:
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Event'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: () => _showAddEventModal(context, ref),
    ),
  ],
),
const SizedBox(height: 10),
// ... event cards follow
```

- [ ] **Step 4: Analyze**

```bash
dart analyze lib/pages/calendar_page.dart
```
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/pages/calendar_page.dart
git commit -m "feat: Add Event button moved above events list, right-aligned"
```

---

## Task 3: Year/Month picker on calendar header

**Problem:** The calendar header currently shows a static "April 2026" subtitle. Clicking month or year should open a picker.

**Files:**
- Modify: `lib/widgets/calendar/month_grid.dart`
- Modify: `lib/providers/calendar_provider.dart` (add `displayMonthProvider` if not already tracking the displayed month/year)

- [ ] **Step 1: Read calendar_provider.dart to understand current state shape**

```bash
cat lib/providers/calendar_provider.dart
```

The provider likely has `selectedDate` (a `DateTime`). The displayed month should derive from `selectedDate`. We need a `displayedMonthProvider` that holds the `DateTime` for the month being viewed (independent of selected date).

- [ ] **Step 2: Add displayedMonthProvider to calendar_provider.dart**

In `lib/providers/calendar_provider.dart`, add:

```dart
// Tracks which month/year the calendar grid is showing
final displayedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(2026, 4), // April 2026 default
);
```

- [ ] **Step 3: Add month/year picker to MonthGrid header**

In `lib/widgets/calendar/month_grid.dart`, replace the static month/year header text with tappable widgets:

```dart
// At the top of MonthGrid's build (or its header section):
// Replace the static "April 2026" Text widgets with:

final displayed = ref.watch(displayedMonthProvider);
final monthName = DateFormat('MMMM').format(displayed); // requires intl
final year = displayed.year;

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Prev month
    IconButton(
      icon: const Icon(Icons.chevron_left, size: 20),
      onPressed: () {
        final cur = ref.read(displayedMonthProvider);
        ref.read(displayedMonthProvider.notifier).state =
            DateTime(cur.year, cur.month - 1);
      },
    ),
    // Tappable Month
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMonthPicker(context, ref, displayed),
        child: Text(
          monthName,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
      ),
    ),
    const SizedBox(width: 4),
    // Tappable Year
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showYearPicker(context, ref, displayed),
        child: Text(
          '$year',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
        ),
      ),
    ),
    // Next month
    IconButton(
      icon: const Icon(Icons.chevron_right, size: 20),
      onPressed: () {
        final cur = ref.read(displayedMonthProvider);
        ref.read(displayedMonthProvider.notifier).state =
            DateTime(cur.year, cur.month + 1);
      },
    ),
  ],
),
```

- [ ] **Step 4: Implement `_showMonthPicker`**

Add this method to the MonthGrid widget class (or as a top-level function in the file):

```dart
void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime current) {
  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Month', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final isSelected = current.month == i + 1;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(displayedMonthProvider.notifier).state =
                          DateTime(current.year, i + 1);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 5: Implement `_showYearPicker`**

```dart
void _showYearPicker(BuildContext context, WidgetRef ref, DateTime current) {
  final years = List.generate(10, (i) => current.year - 3 + i); // 3 before to 6 after
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Year', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: years.map((y) {
                final isSelected = current.year == y;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(displayedMonthProvider.notifier).state =
                          DateTime(y, current.month);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 72, height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 6: Make MonthGrid use displayedMonthProvider for the grid**

Update MonthGrid's grid rendering to use `ref.watch(displayedMonthProvider)` instead of any hardcoded April 2026 date.

Also update `calendar_page.dart` subtitle to read from `displayedMonthProvider`:

```dart
// In calendar_page.dart header:
final displayed = ref.watch(displayedMonthProvider);
Text(DateFormat('MMMM yyyy').format(displayed), style: ...)
```

- [ ] **Step 7: Analyze**

```bash
dart analyze lib/widgets/calendar/month_grid.dart lib/providers/calendar_provider.dart lib/pages/calendar_page.dart
```
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/widgets/calendar/month_grid.dart lib/providers/calendar_provider.dart lib/pages/calendar_page.dart
git commit -m "feat: tappable month/year header opens month and year picker dialogs"
```

---

## Task 4: Group Meeting modal

**Goal:** "Group Meeting" option in Add Event modal opens a secondary modal where the user selects available days and time slots. A shareable mock URL is generated.

**Files:**
- Create: `lib/widgets/calendar/group_meeting_modal.dart`
- Modify: `lib/pages/calendar_page.dart` (add Group Meeting button/option to Add Event modal)

- [ ] **Step 1: Create group_meeting_modal.dart**

```dart
// lib/widgets/calendar/group_meeting_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common/app_modal.dart';

class GroupMeetingModal extends StatefulWidget {
  const GroupMeetingModal({super.key});

  static void show(BuildContext context) {
    AppModal.show(context, title: 'Schedule Group Meeting', child: const GroupMeetingModal());
  }

  @override
  State<GroupMeetingModal> createState() => _GroupMeetingModalState();
}

class _GroupMeetingModalState extends State<GroupMeetingModal> {
  // April 2026 — days 7–30
  final Set<int> _selectedDays = {};
  final Set<String> _selectedSlots = {};
  String? _generatedLink;

  static const _slots = [
    '09:00 – 10:30', '10:40 – 12:10', '13:15 – 14:45',
    '14:55 – 16:25', '16:30 – 18:00', '18:15 – 19:45',
  ];

  @override
  Widget build(BuildContext context) {
    if (_generatedLink != null) return _linkView();
    return _selectionView();
  }

  Widget _selectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Select days you are free', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 10),
        // Day grid (remaining April days)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(24, (i) => i + 7).map((day) {
            final selected = _selectedDays.contains(day);
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (selected) _selectedDays.remove(day); else _selectedDays.add(day);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('2. Select available time slots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 10),
        ..._slots.map((slot) {
          final selected = _selectedSlots.contains(slot);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (selected) _selectedSlots.remove(slot); else _selectedSlots.add(slot);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEEF2FF) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 14, color: selected ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
                      const SizedBox(width: 8),
                      Text(slot, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? const Color(0xFF4F46E5) : const Color(0xFF374151))),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              onPressed: _selectedDays.isEmpty || _selectedSlots.isEmpty ? null : _generateLink,
              child: const Text('Generate Link'),
            ),
          ],
        ),
      ],
    );
  }

  void _generateLink() {
    final days = (_selectedDays.toList()..sort()).join(',');
    final slots = _selectedSlots.length;
    setState(() {
      _generatedLink = 'https://myiuj.iuj.ac.jp/meeting?days=$days&slots=$slots&host=IUJ-2026-0001';
    });
  }

  Widget _linkView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4F46E5), size: 48),
        const SizedBox(height: 12),
        const Text('Meeting link created!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Share this link with your group. They can select their available slots on top of yours.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(child: Text(_generatedLink!, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: _generatedLink!)),
                  child: const Icon(Icons.copy_outlined, size: 18, color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Add Group Meeting option to the Add Event modal in calendar_page.dart**

In `_showAddEventModal` in `calendar_page.dart`, add a "Group Meeting" button after the form:

```dart
// At the bottom of the Add Event modal, before the action buttons row:
const Divider(),
const SizedBox(height: 8),
TextButton.icon(
  icon: const Icon(Icons.group_outlined, size: 16),
  label: const Text('Schedule as Group Meeting instead'),
  style: TextButton.styleFrom(foregroundColor: const Color(0xFF4F46E5)),
  onPressed: () {
    Navigator.of(context).pop(); // close Add Event modal
    GroupMeetingModal.show(context);
  },
),
```

Add import at top of `calendar_page.dart`:
```dart
import '../widgets/calendar/group_meeting_modal.dart';
```

- [ ] **Step 3: Analyze**

```bash
dart analyze lib/widgets/calendar/group_meeting_modal.dart lib/pages/calendar_page.dart
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/calendar/group_meeting_modal.dart lib/pages/calendar_page.dart
git commit -m "feat: Group Meeting modal with day/slot selection and shareable link"
```

---

## Task 5: Final full-project check

- [ ] **Step 1: Full analyze**

```bash
dart analyze lib/
```
Expected: only pre-existing deprecated infos.

- [ ] **Step 2: Run and manually verify**

```bash
flutter run -d chrome
```

Verify:
- [ ] Event cards show type-tag + time + edit/delete in same row; buttons don't cause layout shift
- [ ] Edit/delete are faint at rest and fully opaque on hover
- [ ] Add Event button is right-aligned above the events list (not in page header)
- [ ] Clicking "April" in calendar opens a 12-month grid picker
- [ ] Clicking "2026" opens a year list picker
- [ ] Selecting month/year updates the calendar grid
- [ ] Add Event modal has "Schedule as Group Meeting instead" link
- [ ] Group Meeting modal shows day grid + slot list, generates link on submit
- [ ] Copy icon on generated link copies to clipboard
