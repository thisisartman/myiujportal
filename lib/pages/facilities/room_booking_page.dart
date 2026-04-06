import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/facility.dart';
import '../../models/alert_item.dart';
import '../../data/mock_data.dart';
import '../../providers/facilities_provider.dart';
import '../../providers/alerts_provider.dart';
import '../../widgets/facilities/booking_modal.dart';
import '../../widgets/common/app_modal.dart';
import '../../widgets/common/toast_overlay.dart';

class RoomBookingPage extends ConsumerWidget {
  const RoomBookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomsAndLounges = kFacilities
        .where((f) => f.category == FacilityCategory.classroom || f.category == FacilityCategory.lounge)
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
              child: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 6),
            const Text('Room Booking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Select a space to begin your booking', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        _sectionHeader('Classrooms & Lounges'),
        const SizedBox(height: 12),
        ...classroomsAndLounges.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RoomCard(facility: f, onTap: () => _openBookingModal(context, ref, f)),
        )),
        const SizedBox(height: 16),
        _sectionHeader('Gymnasium'),
        const SizedBox(height: 12),
        ...gymnasiums.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RoomCard(facility: f, onTap: () => _openBookingModal(context, ref, f)),
        )),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151)));
  }

  Future<void> _openBookingModal(BuildContext context, WidgetRef ref, Facility facility) async {
    final result = await AppModal.show<BookingResult>(
      context,
      title: 'Book ${facility.name}',
      child: BookingModal(facility: facility),
    );

    if (result == null || !context.mounted) return;

    // Mark booked slots as unavailable for this session
    ref.read(bookedSlotsProvider.notifier).update((state) {
      final updated = Map<String, Set<String>>.from(state);
      updated[facility.id] = {...(state[facility.id] ?? {}), ...result.slots};
      return updated;
    });

    // Add a dashboard alert
    final newAlert = AlertItem(
      id: 'booking_${facility.id}_${result.day}',
      title: 'Booking Request Received',
      body: 'Your booking request for ${facility.name} on April ${result.day} has been received. You will be notified about the outcome shortly.',
      date: 'Today',
      mailingList: 'my-requests',
      severity: AlertSeverity.info,
    );
    ref.read(alertsProvider.notifier).update((state) => [newAlert, ...state]);

    // Show toast
    if (context.mounted) {
      showToast(context, 'Your request has been submitted. You will be notified about the outcome shortly.');
    }
  }
}

class _RoomCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;

  const _RoomCard({required this.facility, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: facility.bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.meeting_room_outlined, color: facility.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facility.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  _AuthorityChip(label: facility.authority),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }
}

class _AuthorityChip extends StatelessWidget {
  final String label;
  const _AuthorityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
    );
  }
}
