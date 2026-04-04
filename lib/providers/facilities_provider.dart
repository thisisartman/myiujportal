import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/facility.dart';

final selectedFacilityProvider = StateProvider<Facility?>((ref) => null);
final selectedSlotProvider = StateProvider<TimeSlot?>((ref) => null);
final bookingReasonProvider = StateProvider<String>((ref) => '');

enum BookingStatus { idle, confirmed }
final bookingStatusProvider = StateProvider<BookingStatus>((ref) => BookingStatus.idle);
