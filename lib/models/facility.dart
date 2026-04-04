import 'package:flutter/material.dart';

class Facility {
  final String id;
  final String name;
  final String type;
  final String authority;
  final Color bgColor;
  final Color iconColor;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
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
