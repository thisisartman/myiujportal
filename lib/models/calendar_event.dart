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
        return AppColors.primary;
      case CalendarEventType.assignment:
        return AppColors.warning;
      case CalendarEventType.event:
        return AppColors.success;
    }
  }

  Color get bgColor {
    switch (this) {
      case CalendarEventType.class_:
        return AppColors.tealTint2;
      case CalendarEventType.assignment:
        return AppColors.warningLight;
      case CalendarEventType.event:
        return AppColors.successLight;
    }
  }
}

class CalendarEvent {
  final int id;
  final CalendarEventType type;
  final int? year;
  final int? month;
  final int date; // day of month
  final String time; // "HH:MM"
  final String title;
  final String detail;

  const CalendarEvent({
    required this.id,
    required this.type,
    this.year,
    this.month,
    required this.date,
    required this.time,
    required this.title,
    required this.detail,
  });

  CalendarEvent copyWith({
    int? id,
    CalendarEventType? type,
    int? year,
    int? month,
    int? date,
    String? time,
    String? title,
    String? detail,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      year: year ?? this.year,
      month: month ?? this.month,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      detail: detail ?? this.detail,
    );
  }
}
