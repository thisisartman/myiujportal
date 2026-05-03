import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeetingData {
  final String code;
  final String creatorId;
  final String status;
  final DateTime date;
  final int durationMinutes;
  final String repetition;
  final Map<String, List<String>> attendeeAvailability;

  const MeetingData({
    required this.code,
    required this.creatorId,
    required this.status,
    required this.date,
    required this.durationMinutes,
    required this.repetition,
    required this.attendeeAvailability,
  });

  MeetingData copyWith({
    String? status,
    Map<String, List<String>>? attendeeAvailability,
  }) {
    return MeetingData(
      code: code,
      creatorId: creatorId,
      status: status ?? this.status,
      date: date,
      durationMinutes: durationMinutes,
      repetition: repetition,
      attendeeAvailability: attendeeAvailability ?? this.attendeeAvailability,
    );
  }
}

class MeetingNotifier extends Notifier<Map<String, MeetingData>> {
  @override
  Map<String, MeetingData> build() => {};

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
