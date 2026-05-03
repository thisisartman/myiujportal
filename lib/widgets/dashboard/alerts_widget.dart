import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alert_item.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../common/dashboard_card.dart';

class AlertsWidget extends ConsumerWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.notifications_none_outlined,
        text: 'Alerts',
      ),
      actionLabel: '${alerts.length} active',
      onAction: () {},
      flushBody: true,
      child: Column(
        children: alerts
            .map((alert) => _AlertItemRow(alert: alert))
            .toList(growable: false),
      ),
    );
  }
}

class _AlertItemRow extends StatefulWidget {
  final AlertItem alert;

  const _AlertItemRow({required this.alert});

  @override
  State<_AlertItemRow> createState() => _AlertItemRowState();
}

class _AlertItemRowState extends State<_AlertItemRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => AppModal.show(
          context,
          title: alert.title,
          child: Text(
            alert.body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _hovering ? 0.78 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.ruleSofter)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _barColor(alert.severity),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              alert.mailingList,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Read more',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealInk,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  alert.date,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _barColor(AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.info => AppColors.primary,
      AlertSeverity.warning => AppColors.warning,
      AlertSeverity.announcement => AppColors.danger,
    };
  }
}
