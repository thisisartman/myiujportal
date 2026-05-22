import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPrefs {
  final bool bookingAlerts;
  final bool announcementAlerts;
  final bool calendarReminders;

  const NotificationPrefs({
    this.bookingAlerts = true,
    this.announcementAlerts = true,
    this.calendarReminders = true,
  });

  NotificationPrefs copyWith({
    bool? bookingAlerts,
    bool? announcementAlerts,
    bool? calendarReminders,
  }) => NotificationPrefs(
    bookingAlerts: bookingAlerts ?? this.bookingAlerts,
    announcementAlerts: announcementAlerts ?? this.announcementAlerts,
    calendarReminders: calendarReminders ?? this.calendarReminders,
  );
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();
  void update(NotificationPrefs prefs) => state = prefs;
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
      NotificationPrefsNotifier.new,
    );
