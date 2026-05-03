import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CalendarEventType { class_, assignment, event }

extension CalendarEventTypeExtension on CalendarEventType {
  String get label {
    switch (this) {
      case CalendarEventType.class_:
        return 'Classes';
      case CalendarEventType.assignment:
        return 'Assignments';
      case CalendarEventType.event:
        return 'Events';
    }
  }

  Color get color {
    switch (this) {
      case CalendarEventType.class_:
        return const Color(0xFF6366F1); // indigo
      case CalendarEventType.assignment:
        return const Color(0xFFF59E0B); // amber
      case CalendarEventType.event:
        return const Color(0xFF10B981); // emerald
    }
  }

  Color get bgColor {
    switch (this) {
      case CalendarEventType.class_:
        return AppColors.primaryLight;
      case CalendarEventType.assignment:
        return const Color(0xFFFFFBEB);
      case CalendarEventType.event:
        return const Color(0xFFECFDF5);
    }
  }
}

class CalendarEvent {
  final int id;
  final CalendarEventType type;
  final int date; // day of month
  final String time; // "HH:MM"
  final String title;
  final String detail;

  const CalendarEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.title,
    required this.detail,
  });

  CalendarEvent copyWith({
    int? id,
    CalendarEventType? type,
    int? date,
    String? time,
    String? title,
    String? detail,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      detail: detail ?? this.detail,
    );
  }
}
