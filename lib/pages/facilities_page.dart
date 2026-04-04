import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/facilities_provider.dart';
import '../data/mock_data.dart';
import '../widgets/facilities/facility_card.dart';
import '../widgets/facilities/time_slot_selector.dart';
import '../widgets/common/app_modal.dart';
import '../widgets/common/toast_overlay.dart';

class FacilitiesPage extends ConsumerWidget {
  const FacilitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFacility = ref.watch(selectedFacilityProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Facilities Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Book rooms and spaces on campus', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _facilityList()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _bookingPanel(context, ref, selectedFacility, selectedSlot)),
                ],
              )
            : Column(
                children: [
                  _facilityList(),
                  const SizedBox(height: 16),
                  _bookingPanel(context, ref, selectedFacility, selectedSlot),
                ],
              ),
      ],
    );
  }

  Widget _facilityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a Facility', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        ...kFacilities.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FacilityCard(facility: f),
        )),
      ],
    );
  }

  Widget _bookingPanel(BuildContext context, WidgetRef ref, dynamic selectedFacility, dynamic selectedSlot) {
    if (selectedFacility == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.meeting_room_outlined, size: 48, color: Color(0xFFD1D5DB)),
              SizedBox(height: 12),
              Text('Select a facility to see availability', style: TextStyle(color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
    }

    final reasonController = TextEditingController(text: ref.read(bookingReasonProvider));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedFacility.bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.meeting_room_outlined, color: selectedFacility.iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedFacility.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const TimeSlotSelector(),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            onChanged: (v) => ref.read(bookingReasonProvider.notifier).state = v,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason for booking',
              hintText: 'Brief description of your planned use...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSlot != null ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: selectedSlot != null
                  ? () => _confirmBooking(context, ref, selectedFacility, selectedSlot)
                  : null,
              child: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context, WidgetRef ref, dynamic facility, dynamic slot) {
    AppModal.show(
      context,
      title: 'Confirm Booking',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Facility', facility.name),
          const SizedBox(height: 8),
          _infoRow('Date', 'Wednesday, April 1, 2026'),
          const SizedBox(height: 8),
          _infoRow('Time', slot.time),
          const SizedBox(height: 8),
          if (ref.read(bookingReasonProvider).isNotEmpty)
            _infoRow('Reason', ref.read(bookingReasonProvider)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(selectedSlotProvider.notifier).state = null;
                  ref.read(bookingReasonProvider.notifier).state = '';
                  showToast(context, 'Booking confirmed for ${facility.name}!');
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
