import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/facilities_provider.dart';
import '../../data/mock_data.dart';

class TimeSlotSelector extends ConsumerWidget {
  const TimeSlotSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlot = ref.watch(selectedSlotProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Time Slots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        ...kMockSlots.map((slot) {
          final isSelected = selectedSlot?.time == slot.time;
          return GestureDetector(
            onTap: slot.available
                ? () => ref.read(selectedSlotProvider.notifier).state = isSelected ? null : slot
                : null,
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
                  Text(
                    slot.time,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: slot.available ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: slot.available
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      slot.available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: slot.available ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
