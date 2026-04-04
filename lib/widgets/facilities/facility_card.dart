import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/facility.dart';
import '../../providers/facilities_provider.dart';

class FacilityCard extends ConsumerWidget {
  final Facility facility;
  const FacilityCard({super.key, required this.facility});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFacilityProvider);
    final isSelected = selected?.id == facility.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedFacilityProvider.notifier).state = facility;
        ref.read(selectedSlotProvider.notifier).state = null;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: facility.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.meeting_room_outlined, color: facility.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facility.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Chip(label: facility.type, color: const Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      _Chip(label: facility.authority, color: const Color(0xFF6B7280)),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
