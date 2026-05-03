import '../../models/calendar_event.dart';

class DashboardEventMeta {
  final String? professor;
  final String? course;
  final String? room;

  const DashboardEventMeta({this.professor, this.course, this.room});
}

DashboardEventMeta parseDashboardEventMeta(String detail) {
  final parts = detail.split('|').map((part) => part.trim()).toList();
  String? professor;
  String? course;
  String? room;
  for (final part in parts) {
    final normalized = part.replaceAll('-', '').replaceAll(' ', '');
    if (RegExp(r'^[A-Z]{2,5}\d{4,5}$').hasMatch(normalized)) {
      course = normalized;
    } else if (RegExp(
      r'(G\.|P\.|Hall|Room|Cafeteria|Library|Gym)',
    ).hasMatch(part)) {
      room = part;
    } else if (RegExp(r'[A-Za-z]').hasMatch(part)) {
      professor = part;
    }
  }
  return DashboardEventMeta(professor: professor, course: course, room: room);
}

String dashboardCourseId(String code) => code.replaceAll('-', '').toLowerCase();

DateTime dashboardEventDateTime(CalendarEvent event, {DateTime? baseDate}) {
  final base = baseDate ?? DateTime.now();
  final parts = event.time.split(':');
  return DateTime(
    event.year ?? base.year,
    event.month ?? base.month,
    event.date,
    int.tryParse(parts.first) ?? 0,
    parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
  );
}

bool isDashboardEventOnDate(CalendarEvent event, DateTime date) {
  return event.year == date.year &&
      event.month == date.month &&
      event.date == date.day;
}
