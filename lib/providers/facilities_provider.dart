import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maps facilityId → set of slot time strings that have been booked this session.
final bookedSlotsProvider = StateProvider<Map<String, Set<String>>>((ref) => {});
