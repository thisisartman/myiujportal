import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../widgets/facilities/expandable_room_card.dart';
import '../../widgets/common/page_chrome.dart';

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
        PageGreeting(
          title: 'Room Booking',
          meta: const [
            MetaText('Select a space to begin your booking'),
            MetaDot(),
            MetaText('Managed by OAA, OGA, OSS and MLIC', emphasis: true),
          ],
          actions: OutlinedButton.icon(
            onPressed: () => context.go('/facilities'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Facilities'),
          ),
        ),
        const SizedBox(height: 18),
        SearchPanel(
          hint: 'Search rooms, lounges, amenities...',
          onChanged: (_) {},
          trailing: const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SoftChip(label: 'All', selected: true),
              SoftChip(label: 'Classrooms'),
              SoftChip(label: 'Lounges'),
              SoftChip(label: 'Gymnasium'),
              SoftChip(label: 'Favorites only', icon: Icons.favorite_border),
            ],
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final main = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  'Classrooms & Lounges',
                  classroomsAndLounges,
                  constraints.maxWidth,
                  isWide,
                ),
                const SizedBox(height: 24),
                _section('Gymnasium', gymnasiums, constraints.maxWidth, isWide),
              ],
            );
            final aside = Column(
              children: [
                const PageCard(
                  header: PageCardHeader(
                    icon: Icons.calendar_today_outlined,
                    title: 'My reservations',
                  ),
                  child: Column(
                    children: [
                      _ReservationRow(
                        title: 'MLIC Study Room A',
                        meta: 'Today · 19:00-20:30',
                        status: 'Confirmed',
                        confirmed: true,
                      ),
                      Divider(height: 22),
                      _ReservationRow(
                        title: 'CNP Snack Lounge',
                        meta: 'May 15 · 16:30-18:00',
                        status: 'Pending',
                        confirmed: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PageCard(
                  header: const PageCardHeader(
                    icon: Icons.star_border,
                    title: 'Favorites',
                  ),
                  child: Column(
                    children: classroomsAndLounges.take(3).map((facility) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                facility.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SoftChip(label: 'Book', selected: true),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
            if (!isWide) {
              return Column(
                children: [main, const SizedBox(height: 18), aside],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: main),
                const SizedBox(width: 18),
                SizedBox(width: 320, child: aside),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _section(
    String title,
    List<Facility> facilities,
    double width,
    bool isWide,
  ) {
    final columns = isWide ? 2 : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title.toUpperCase(),
            children: [
              TextSpan(
                text: '  · ${facilities.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: facilities.map((facility) {
            final cardWidth = columns == 1 ? width : (width - 12) / 2;
            return SizedBox(
              width: cardWidth.clamp(260.0, 560.0),
              child: ExpandableRoomCard(facility: facility),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ReservationRow extends StatelessWidget {
  final String title;
  final String meta;
  final String status;
  final bool confirmed;

  const _ReservationRow({
    required this.title,
    required this.meta,
    required this.status,
    required this.confirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: confirmed ? AppColors.successLight : AppColors.warningLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: confirmed ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}
