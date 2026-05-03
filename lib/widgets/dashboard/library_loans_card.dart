import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../common/dashboard_card.dart';

class LibraryLoansCard extends StatelessWidget {
  const LibraryLoansCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loans = kMockLibraryLoans.take(3).toList();
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.local_library_outlined,
        text: 'Library loans',
      ),
      actionLabel: 'Open library',
      onAction: () => context.go('/facilities/library'),
      child: Column(
        children: [
          ...loans.map((loan) => _LoanRow(loan: loan)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/facilities/library'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.tealInk,
                side: const BorderSide(color: AppColors.rule),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Renew all loans'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanRow extends StatelessWidget {
  final ({String title, String author, String dueDate, bool overdue}) loan;

  const _LoanRow({required this.loan});

  @override
  Widget build(BuildContext context) {
    final due = _parseDueDate(loan.dueDate);
    final daysUntilDue = due.difference(DateTime.now()).inDays;
    final status = daysUntilDue < 0
        ? _LoanStatus.overdue
        : (daysUntilDue <= 5 ? _LoanStatus.dueSoon : _LoanStatus.normal);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgSunken,
              borderRadius: BorderRadius.circular(3),
              border: Border(left: BorderSide(color: status.color, width: 4)),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loan.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: status.color,
                  ),
                ),
                Text(
                  due.day.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: status.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseDueDate(String dueDate) {
    return DateFormat('MMM d, yyyy').parse(dueDate);
  }
}

enum _LoanStatus {
  normal('DUE', AppColors.tealInk),
  dueSoon('DUE', AppColors.warning),
  overdue('OVERDUE', AppColors.danger);

  final String label;
  final Color color;

  const _LoanStatus(this.label, this.color);
}
