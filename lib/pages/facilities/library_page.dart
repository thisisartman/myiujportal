import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_data.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/common/page_chrome.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Library',
          meta: const [
            MetaText('Matsushita Library & Information Center'),
            MetaDot(),
            MetaText('Loans, journals and catalogue access', emphasis: true),
          ],
          actions: OutlinedButton.icon(
            onPressed: () => context.go('/facilities'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Facilities'),
          ),
        ),
        const SizedBox(height: 18),
        SearchPanel(
          hint: 'Search MLIC catalogue, journals, reports...',
          onChanged: (_) {},
          trailing: const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SoftChip(label: 'Academic Journals'),
              SoftChip(label: 'Yearbooks'),
              SoftChip(label: 'E-Databases'),
              SoftChip(label: 'Renewals', selected: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final loans = PageCard(
              header: const PageCardHeader(
                icon: Icons.menu_book_outlined,
                title: 'My loans',
              ),
              child: Column(
                children: kMockLibraryLoans.indexed.map((entry) {
                  final (i, loan) = entry;
                  return Column(
                    children: [
                      if (i > 0) const Divider(height: 24),
                      _LoanRow(loan: loan),
                    ],
                  );
                }).toList(),
              ),
            );
            final resources = PageCard(
              header: const PageCardHeader(
                icon: Icons.dataset_outlined,
                title: 'Library resources',
              ),
              child: Column(
                children: _resources
                    .map(
                      (resource) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ResourceRow(resource: resource),
                      ),
                    )
                    .toList(),
              ),
            );
            if (!isWide) {
              return Column(
                children: [loans, const SizedBox(height: 16), resources],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: loans),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: resources),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open MLIC Catalogue'),
            onPressed: () async {
              final uri = Uri.parse('https://mlic.iuj.ac.jp/opac/');
              if (await canLaunchUrl(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _LoanRow extends StatelessWidget {
  final ({String title, String author, String dueDate, bool overdue}) loan;

  const _LoanRow({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bgSunken,
            borderRadius: BorderRadius.circular(3),
            border: Border(
              left: BorderSide(
                color: loan.overdue ? AppColors.danger : AppColors.primary,
                width: 4,
              ),
            ),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            size: 18,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 12),
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${loan.author} · Due ${loan.dueDate}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: loan.overdue
                ? AppColors.dangerLight
                : AppColors.successLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            loan.overdue ? 'Overdue' : 'On time',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: loan.overdue ? AppColors.danger : AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final (IconData, String, String) resource;

  const _ResourceRow({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ruleSofter),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tealTint2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(resource.$1, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.$2,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  resource.$3,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// (icon, title, description) — positional records
const _resources = [
  (
    Icons.article_outlined,
    'Academic Journals',
    'Access JSTOR, EBSCOhost, and other subscribed databases',
  ),
  (
    Icons.menu_book_outlined,
    'Yearbooks & Reports',
    'IUJ annual reports, alumni directories, and institutional publications',
  ),
  (
    Icons.computer_outlined,
    'E-Databases',
    'Nikkei Telecom, Bloomberg, World Bank Open Data, and more',
  ),
];
