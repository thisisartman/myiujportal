import 'package:flutter/material.dart';
import '../../models/facility.dart';

class BookingSlotSelector extends StatelessWidget {
  final List<TimeSlot> slots;
  final Set<String> selectedSlots;
  final void Function(String time) onToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BookingSlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlots,
    required this.onToggle,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Time Slots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        const Text('You may select multiple available slots.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 12),
        ...slots.map((slot) {
          final isSelected = selectedSlots.contains(slot.time);
          return GestureDetector(
            onTap: slot.available ? () => onToggle(slot.time) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: !slot.available
                    ? const Color(0xFFF3F4F6)
                    : isSelected
                        ? const Color(0xFFEEF2FF)
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: !slot.available
                      ? const Color(0xFFE5E7EB)
                      : isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFD1D5DB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    slot.available ? Icons.access_time : Icons.block,
                    size: 16,
                    color: slot.available ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: slot.available ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: !slot.available
                          ? const Color(0xFFFEE2E2)
                          : isSelected
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      !slot.available ? 'Unavailable' : isSelected ? 'Selected' : 'Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: !slot.available
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSlots.isNotEmpty ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: selectedSlots.isNotEmpty ? onNext : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
