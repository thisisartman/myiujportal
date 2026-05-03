import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, announcement }

extension AlertSeverityExt on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.info:
        return const Color(0xFF2563EB);
      case AlertSeverity.warning:
        return const Color(0xFFD97706);
      case AlertSeverity.announcement:
        return const Color(0xFF7C3AED);
    }
  }

  Color get bgColor {
    switch (this) {
      case AlertSeverity.info:
        return const Color(0xFFDBEAFE);
      case AlertSeverity.warning:
        return const Color(0xFFFEF3C7);
      case AlertSeverity.announcement:
        return const Color(0xFFF5F3FF);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.announcement:
        return Icons.campaign_outlined;
    }
  }

  String get label {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Notice';
      case AlertSeverity.announcement:
        return 'Announcement';
    }
  }
}

class AlertItem {
  final String id;
  final String title;
  final String body;
  final String date;
  final String mailingList;
  final AlertSeverity severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.mailingList,
    required this.severity,
  });
}
