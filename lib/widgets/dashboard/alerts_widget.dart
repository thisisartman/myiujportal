import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/alert_item.dart';

class AlertsWidget extends StatelessWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_none_outlined, size: 18, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                const Text('Alerts & News', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${kMockAlerts.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: kMockAlerts.map((alert) => _AlertRow(alert: alert)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatefulWidget {
  final AlertItem alert;
  const _AlertRow({required this.alert});
  @override
  State<_AlertRow> createState() => _AlertRowState();
}

class _AlertRowState extends State<_AlertRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: a.severity.bgColor, borderRadius: BorderRadius.circular(6)),
                    child: Icon(a.severity.icon, color: a.severity.color, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                            ),
                            Text(a.date, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: a.severity.bgColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(a.mailingList, style: TextStyle(fontSize: 10, color: a.severity.color, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16, color: const Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 0, 14, 10),
            child: Text(a.body, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
