import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeetingData {
  final String code;
  final String creatorId;
  final String status;
  final DateTime date;
  final int durationMinutes;
  final String repetition;
  final int totalInvitees;
  final Map<String, List<String>> attendeeAvailability;

  const MeetingData({
    required this.code,
    required this.creatorId,
    required this.status,
    required this.date,
    required this.durationMinutes,
    required this.repetition,
    this.totalInvitees = 4,
    required this.attendeeAvailability,
  });

  MeetingData copyWith({
    String? status,
    int? totalInvitees,
    Map<String, List<String>>? attendeeAvailability,
  }) {
    return MeetingData(
      code: code,
      creatorId: creatorId,
      status: status ?? this.status,
      date: date,
      durationMinutes: durationMinutes,
      repetition: repetition,
      totalInvitees: totalInvitees ?? this.totalInvitees,
      attendeeAvailability: attendeeAvailability ?? this.attendeeAvailability,
    );
  }
}

class MeetingNotifier extends Notifier<Map<String, MeetingData>> {
  @override
  Map<String, MeetingData> build() {
    final now = DateTime.now();
    return {
      'SD1SYNC': MeetingData(
        code: 'SD1SYNC',
        creatorId: 'IUJ-2026-0001', // not current user → receiver view
        status: 'pending',
        date: DateTime(now.year, now.month + 1, 5),
        durationMinutes: 60,
        repetition: 'None',
        totalInvitees: 5,
        attendeeAvailability: {
          'IUJ-2026-0001': ['09:00', '10:00', '13:00', '15:00'],
          'IUJ-2026-0042': ['09:00', '13:00'],
          'IUJ-2026-0078': ['10:00', '13:00'],
        },
      ),
    };
  }

  void addMeeting(MeetingData meeting) {
    state = {...state, meeting.code: meeting};
  }

  void submitAttendeeAvailability(
    String code,
    String attendeeId,
    List<String> slots,
  ) {
    final meeting = state[code];
    if (meeting == null) return;
    state = {
      ...state,
      code: meeting.copyWith(
        attendeeAvailability: {
          ...meeting.attendeeAvailability,
          attendeeId: slots,
        },
      ),
    };
  }

  void confirmMeeting(String code) {
    final meeting = state[code];
    if (meeting == null) return;
    state = {...state, code: meeting.copyWith(status: 'confirmed')};
  }
}

final meetingProvider =
    NotifierProvider<MeetingNotifier, Map<String, MeetingData>>(
      MeetingNotifier.new,
    );
