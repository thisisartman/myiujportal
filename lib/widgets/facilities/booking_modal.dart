import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../providers/facilities_provider.dart';
import 'booking_calendar.dart';
import 'booking_slot_selector.dart';
import 'booking_form.dart';

/// Returned when the user completes the booking flow.
typedef BookingResult = ({
  int day,
  Set<String> slots,
  Map<String, String> formData,
});

class BookingModal extends ConsumerStatefulWidget {
  final Facility facility;

  const BookingModal({super.key, required this.facility});

  @override
  ConsumerState<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends ConsumerState<BookingModal> {
  int _step = 1;
  int? _selectedDay;
  Set<String> _selectedSlots = {};

  List<TimeSlot> _effectiveSlots() {
    final booked = ref.watch(bookedSlotsProvider)[widget.facility.id] ?? {};
    return kMockSlots.map((s) {
      if (booked.contains(s.time)) {
        return TimeSlot(time: s.time, available: false);
      }
      return s;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepIndicator(),
        const SizedBox(height: 16),
        if (_step == 1)
          BookingCalendar(
            facilityId: widget.facility.id,
            onDaySelected: (day) => setState(() {
              _selectedDay = day;
              _selectedSlots = {};
              _step = 2;
            }),
          ),
        if (_step == 2)
          BookingSlotSelector(
            slots: _effectiveSlots(),
            selectedSlots: _selectedSlots,
            onToggle: (time) => setState(() {
              _selectedSlots.contains(time)
                  ? _selectedSlots.remove(time)
                  : _selectedSlots.add(time);
            }),
            onNext: () => setState(() => _step = 3),
            onBack: () => setState(() => _step = 1),
          ),
        if (_step == 3)
          BookingForm(
            category: widget.facility.category,
            onBack: () => setState(() => _step = 2),
            onSubmit: (formData) {
              Navigator.of(context).pop<BookingResult>((
                day: _selectedDay!,
                slots: Set<String>.from(_selectedSlots),
                formData: formData,
              ));
            },
          ),
      ],
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: [
        Text(
          'Step $_step of 3',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: _step / 3,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
