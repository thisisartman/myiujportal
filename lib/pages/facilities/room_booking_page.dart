import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../widgets/facilities/expandable_room_card.dart';

class RoomBookingPage extends ConsumerWidget {
  const RoomBookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomsAndLounges = kFacilities
        .where(
          (f) =>
              f.category == FacilityCategory.classroom ||
              f.category == FacilityCategory.lounge,
        )
        .toList();
    final gymnasiums = kFacilities
        .where((f) => f.category == FacilityCategory.gymnasium)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/facilities'),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Room Booking',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Select a space to begin your booking',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _sectionHeader('Classrooms & Lounges'),
        const SizedBox(height: 12),
        ...classroomsAndLounges.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpandableRoomCard(facility: f),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader('Gymnasium'),
        const SizedBox(height: 12),
        ...gymnasiums.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpandableRoomCard(facility: f),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
