// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard/upcoming_events_widget.dart';
import '../widgets/dashboard/quick_links_widget.dart';
import '../widgets/dashboard/alerts_widget.dart';
import '../widgets/dashboard/digital_id_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Good morning, Student!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Wednesday, April 1, 2026',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        // Digital ID — full width
        const DigitalIdWidget(),
        const SizedBox(height: 16),

        // Main 2-column layout (or stacked on mobile)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Upcoming Events (wider)
                  const Expanded(flex: 5, child: UpcomingEventsWidget()),
                  const SizedBox(width: 16),
                  // Right: Quick Links + Alerts
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: const [
                        QuickLinksWidget(),
                        SizedBox(height: 16),
                        AlertsWidget(),
                      ],
                    ),
                  ),
                ],
              )
            : const Column(
                children: [
                  UpcomingEventsWidget(),
                  SizedBox(height: 16),
                  QuickLinksWidget(),
                  SizedBox(height: 16),
                  AlertsWidget(),
                ],
              ),
      ],
    );
  }
}
