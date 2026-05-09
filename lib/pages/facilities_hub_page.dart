import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../widgets/common/page_chrome.dart';

class FacilitiesHubPage extends StatelessWidget {
  const FacilitiesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageGreeting(
          title: 'Facilities',
          meta: [
            MetaText('Book rooms, lounges, and the gymnasium'),
            MetaDot(),
            MetaText('6 available now', emphasis: true),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 860;
            final cards = [
              _HubCard(
                icon: Icons.meeting_room_outlined,
                iconBg: AppColors.tealTint2,
                iconColor: AppColors.primary,
                title: 'Room Booking',
                subtitle: 'Reserve classrooms, lounges, and the gymnasium',
                route: '/facilities/room-booking',
              ),
              _HubCard(
                icon: Icons.local_library_outlined,
                iconBg: AppColors.warningLight,
                iconColor: AppColors.warning,
                title: 'Library',
                subtitle:
                    'View your loans, explore resources, and search the catalogue',
                route: '/facilities/library',
              ),
              _HubCard(
                icon: Icons.people_outline,
                iconBg: AppColors.successLight,
                iconColor: AppColors.success,
                title: 'Campus Directory',
                subtitle:
                    'Find students, faculty, staff, and campus organisations',
                route: '/facilities/directory',
              ),
            ];
            if (!isWide) {
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards.indexed.map((entry) {
                final (index, card) = entry;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 14),
                    child: card,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String route;

  const _HubCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ruleSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Text(
                  'Open',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealInk,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.tealInk),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
