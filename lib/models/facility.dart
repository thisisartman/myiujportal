import 'package:flutter/material.dart';

enum FacilityCategory { classroom, lounge, gymnasium }

class Facility {
  final String id;
  final String name;
  final FacilityCategory category;
  final String authority;
  final Color bgColor;
  final Color iconColor;

  const Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.authority,
    required this.bgColor,
    required this.iconColor,
  });
}

class TimeSlot {
  final String time;
  final bool available;

  const TimeSlot({required this.time, required this.available});
}
