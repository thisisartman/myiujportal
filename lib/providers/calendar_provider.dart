import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../data/mock_data.dart';

// The month being viewed (default: April 2026)
final currentViewDateProvider = StateProvider<DateTime>((ref) => DateTime(2026, 4, 1));

// The selected day of the month
final selectedDateProvider = StateProvider<int>((ref) => 1);

// Filter: 'all', 'class_', 'assignment', 'event'
final calendarFilterProvider = StateProvider<String>((ref) => 'all');

// Calendar view mode
enum CalendarViewMode { month, week }
final calendarViewModeProvider = StateProvider<CalendarViewMode>((ref) => CalendarViewMode.month);

// The mutable list of events
class CalendarEventsNotifier extends Notifier<List<CalendarEvent>> {
  @override
  List<CalendarEvent> build() => List.from(kInitialCalendarEvents);

  void addEvent(CalendarEvent event) {
    state = [...state, event];
  }

  void updateEvent(CalendarEvent updated) {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e,
    ];
  }

  void deleteEvent(int id) {
    state = state.where((e) => e.id != id).toList();
  }

  int get nextId => state.isEmpty ? 1 : state.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
}

final calendarEventsProvider = NotifierProvider<CalendarEventsNotifier, List<CalendarEvent>>(
  CalendarEventsNotifier.new,
);

// Derived: events for selected date, filtered
final filteredEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final events = ref.watch(calendarEventsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final filter = ref.watch(calendarFilterProvider);
  ref.watch(currentViewDateProvider); // reactive to month changes

  var dayEvents = events.where((e) {
    // Only show events for the currently viewed month
    return e.date == selectedDate;
  }).toList();

  if (filter != 'all') {
    dayEvents = dayEvents.where((e) => e.type.name == filter).toList();
  }

  dayEvents.sort((a, b) => a.time.compareTo(b.time));
  return dayEvents;
});

// All events for the current view month (for dot indicators)
final monthEventsProvider = Provider<Map<int, List<CalendarEvent>>>((ref) {
  final events = ref.watch(calendarEventsProvider);
  final Map<int, List<CalendarEvent>> map = {};
  for (final e in events) {
    map.putIfAbsent(e.date, () => []).add(e);
  }
  return map;
});
