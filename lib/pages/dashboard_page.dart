// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard/upcoming_events_widget.dart';
import '../widgets/dashboard/quick_links_widget.dart';
import '../widgets/dashboard/alerts_widget.dart';
import '../widgets/dashboard/profile_dropdown.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    const header = _DashboardHeader();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 5, child: UpcomingEventsWidget()),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        header,
                        const SizedBox(height: 16),
                        QuickLinksWidget(),
                        const SizedBox(height: 16),
                        AlertsWidget(),
                      ],
                    ),
                  ),
                ],
              )
            : const Column(
                children: [
                  _DashboardHeader(),
                  SizedBox(height: 16),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final effectiveToday = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning, Student!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(effectiveToday),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Spring term 2026',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const ProfileChip(),
      ],
    );
  }
}
