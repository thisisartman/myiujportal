import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FacilitiesHubPage extends StatelessWidget {
  const FacilitiesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Facilities Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Book rooms, access the library, and explore the campus directory', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        _HubCard(
          icon: Icons.meeting_room_outlined,
          iconBg: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          title: 'Room Booking',
          subtitle: 'Reserve classrooms, lounges, and the gymnasium',
          route: '/facilities/room-booking',
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.local_library_outlined,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Library',
          subtitle: 'View your loans, explore resources, and search the catalogue',
          route: '/facilities/library',
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.people_outline,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          title: 'Campus Directory',
          subtitle: 'Find students, faculty, staff, and campus organisations',
          route: '/facilities/directory',
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
