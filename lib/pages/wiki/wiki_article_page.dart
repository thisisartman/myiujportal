import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../widgets/wiki/breadcrumb_bar.dart';
import '../../widgets/common/app_modal.dart';
import '../../widgets/common/hover_card.dart';
import '../../theme/app_colors.dart';

/// Handles all wiki routes: category pages, subcategory pages, and articles.
class WikiArticlePage extends ConsumerWidget {
  final String articleId;
  const WikiArticlePage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = kWikiPages[articleId] ?? kWikiPages['category-$articleId'];

    if (page == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Page Not Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go('/wiki'),
            child: const Text('Back to Wiki Home'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BreadcrumbBar(pageId: articleId),
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(page.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${page.lastUpdated}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Suggest Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _showSuggestEdit(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // Page content
        _buildContent(context, articleId),
      ],
    );
  }

  Widget _buildContent(BuildContext context, String id) {
    // Support both 'courses' and 'category-courses' as the same page
    final normalizedId = kWikiPages.containsKey(id) ? id : 'category-$id';
    switch (normalizedId) {
      case 'category-courses':
        return _CoursesCategory(context: context);
      case 'subcategory-finance':
        return _SubcategoryPage(
          description: 'The Finance specialization equips students with analytical tools to navigate global markets, sustainable investing, and emerging fintech applications.',
          courses: [
            ('course-fin2090', 'FIN2090: Behavioral Finance'),
            ('course-fin2080', 'FIN2080: Sustainable Finance & Investment'),
            ('course-fin3020', 'FIN3020: Finance and Technology'),
          ],
          context: context,
        );
      case 'subcategory-it-operations':
        return _SubcategoryPage(
          description: 'Explore syllabi covering data science, digital transformation (DX), and the management of organizational processes.',
          courses: [
            ('course-itc1080', 'ITC1080: Data-Driven Organization'),
            ('course-itc2080', 'ITC2080: Management for Digital Transformation'),
            ('course-itc2020', 'ITC2020: Big Data Analytics'),
            ('course-opr1010', 'OPR1010: Operations Management'),
          ],
          context: context,
        );
      case 'subcategory-general-management':
        return _SubcategoryPage(
          description: 'Core management topics covering international strategy, entrepreneurship, and organizational control.',
          courses: [
            ('course-mgt1130', 'MGT1130: International Management'),
            ('course-mgt1140', 'MGT1140: Business Decision-Making and Control'),
            ('course-mgt2120', 'MGT2120: Entrepreneurship & Small Business Dev.'),
          ],
          context: context,
        );
      case 'category-residential-life':
        return _ResidentialLifeCategory(context: context);
      case 'category-academics':
        return _AcademicsCategory(context: context);
      case 'category-gso':
        return _PlaceholderCategory(
          icon: Icons.group_outlined,
          message: 'GSO Guidelines, Event Planning, and Budget Processes will be published here.',
        );
      case 'category-administration':
        return _AdminCategory(context: context);
      case 'winter-survival':
        return const _WinterSurvivalArticle();
      case 'trash-mastery':
        return const _TrashMasteryArticle();
      case 'urasa-station':
        return const _UrasaStationArticle();
      case 'device-calendar':
        return const _DeviceCalendarArticle();
      case 'course-fin2090':
        return _CourseArticle(
          instructor: 'Yanghua Shi',
          schedule: 'Fri 10:30-12:00, 13:00-14:30',
          credits: '2 Credits',
          description: 'This course will give you an overview of how psychological biases and cognitive limitations shape financial decisions, market behavior, and investment outcomes, with a focus on real-world applications in business and finance.',
          objective: 'In today\'s complex financial landscape, understanding how people actually make decisions is critical for designing effective business strategies and financial products. The objective is to provide an overview of key concepts in behavioral finance, including how cognitive biases, emotions, and social influences affect financial decision-making.',
          objectiveLabel: 'Learning Objectives',
        );
      case 'course-fin2080':
        return _CourseArticle(
          instructor: 'Chow, Yuen Leng',
          schedule: 'Tue 2nd & 3rd Period',
          credits: '2 Credits',
          description: 'Students will be given an overview of the financial markets and the new investment trends of sustainable finance. This course focuses on three core components: environment, social, and governance (ESG).',
          objective: 'This course aims to provide students with an understanding of the linkages between global capital markets and funding environment, social and governance (ESG) related projects.',
          objectiveLabel: 'Learning Objectives',
        );
      case 'course-fin3020':
        return _CourseArticle(
          instructor: 'Chow, Yuen Leng',
          schedule: 'Mon 2nd & 3rd Period',
          credits: '2 Credits',
          description: 'In this course, you will be given an overview of finance and technology (fintech). What is fintech, when did it originate, what are the major trends going forward. The course will also provide an introduction to digital currencies and blockchain.',
          objective: 'Fintech is increasingly changing the way for payments and investing. You will gain an understanding of the complex structure of payment methods and financial regulations, and employ strategies in developing a fintech strategy for your business.',
          objectiveLabel: 'Career Relevance',
        );
      case 'course-itc1080':
        return _CourseArticleWithList(
          instructor: 'Zaw Zaw Aung',
          schedule: 'Monday 4th & 5th Period',
          credits: '2 Credits',
          description: 'Companies are embracing Digital Transformation (DX) as their main agenda. Yet being more "digital" or collecting more data won\'t get the companies very far if there aren\'t methods and tools to better the management process.',
          listLabel: 'Core Topics',
          listItems: [
            'Creating Data-Driven Organization Culture',
            'Alignment of Data Strategy with Business Strategy',
            'Data Engineering, Self-service Data Platform and Data Mesh',
            'Data Quality, Data Literacy, Data Governance',
          ],
        );
      case 'course-itc2080':
        return _CourseArticle(
          instructor: 'Sakurai, Mihoko',
          schedule: 'Wed 14:40-16:10, 16:20-17:50',
          credits: '2 Credits',
          description: 'This course provides essential frameworks and associated keywords that help to understand digital transformation (DX). The course aims to investigate three core topics: DX process, DX structure, and DX culture within an organization.',
          objective: 'Discussions around these themes are based on the notion of "sociotechnical system" which regards a work system as correlative interacting systems of the social system and the technical system.',
          objectiveLabel: 'Approach',
        );
      case 'course-itc2020':
        return _CourseArticle(
          instructor: 'Zaw Zaw Aung',
          schedule: 'Fri 2nd & 3rd Period',
          credits: '2 Credits',
          description: 'This course is for those new to data science and interested in understanding why the Big Data Era has come to be. This course introduces you data-analytic thinking.',
          objective: 'Recognize different data elements in your own work, explain why your team needs to design a Big Data Infrastructure Plan, select a data model, retrieve data, process patterns, and design an approach leveraging machine learning processes.',
          objectiveLabel: 'Learning Objectives',
        );
      case 'course-opr1010':
        return _CourseArticle(
          instructor: 'Wenkai Li',
          schedule: 'Mon/Tue 14:40 - 17:50',
          credits: '2 Credits',
          description: 'Operations is one of three basic functions/pillars in any business organization. Operations Management (OM) is the management of systems or processes that create goods and/or provide services, within an organization.',
          objective: 'Students will familiarize with basic knowledge of production and processes, including a strategic view of operations management, process thinking, lean thinking, quality management, and inventory management. Japanese way of operations will also be introduced.',
          objectiveLabel: 'Learning Objectives',
        );
      case 'course-mgt1130':
        return _CourseArticleWithList(
          instructor: 'Yingying Zhang Zhang',
          schedule: 'Wed Per 4-5 OR Thu Per 2-3',
          credits: '2 Credits',
          description: 'This course of international management is designed to equip students with essential knowledge and skills for effective management within the global business landscape.',
          listLabel: 'Course Content',
          listItems: [
            'Foundations of Global Business',
            'Analytical Tools for Internationalization',
            'Navigating International Competitive Environments',
            'Global Strategic Management',
          ],
        );
      case 'course-mgt1140':
        return _CourseArticle(
          instructor: 'Lee, Hyunkoo',
          schedule: 'Wed 10:30 AM & 1:00 PM',
          credits: '2 Credits',
          description: 'This course introduces students to the evolving role of managerial accounting in modern business environments. Topics include cost estimation, cost analysis, activity-based costing, cost-volume-profits analysis, budgets and standards.',
          objective: 'The course highlights the informational needs of managers in planning, controlling, and decision making, and shows how to take advantage of accounting data in various situations.',
          objectiveLabel: 'Learning Objectives',
        );
      case 'course-mgt2120':
        return _CourseArticle(
          instructor: 'Remy Magnier-Watanabe',
          schedule: 'Thu 14:40 - 17:50',
          credits: '2 Credits',
          description: 'This course is particularly useful for students who are interested in starting their own business and want to learn different aspects of business management.',
          objective: 'Evaluate qualities of the successful entrepreneurial profile; determine the steps necessary to open and operate a small business enterprise; identify marketing and financial competencies; and ultimately develop and present a Business Plan.',
          objectiveLabel: 'Learning Objectives',
        );
      // GSIR subcategory landing pages
      case 'subcategory-intl-relations':
        return _SubcategoryPage(
          description: 'The International Relations Program (IRP) prepares graduates to analyze global political dynamics, security studies, and diplomacy. Students earn an MA in International Relations or MA in Political Science.',
          courses: const [],
          context: context,
          emptyMessage: 'IRP course syllabi will be published here by the GSIR faculty.',
        );
      case 'subcategory-intl-development':
        return _SubcategoryPage(
          description: 'The International Development Program (IDP) focuses on economic development, poverty reduction, and policy analysis in developing contexts. Graduates earn an MA in International Development or MA in Economics.',
          courses: const [],
          context: context,
          emptyMessage: 'IDP course syllabi will be published here by the GSIR faculty.',
        );
      case 'subcategory-public-management':
        return _SubcategoryPage(
          description: 'The Public Management and Policy Analysis Program (PMPP) trains future public servants and policy analysts. Graduates earn an MA in Public Management or MA in Public Policy.',
          courses: const [],
          context: context,
          emptyMessage: 'PMPP course syllabi will be published here by the GSIR faculty.',
        );

      // Administration pages
      case 'about-iuj':
        return const _AboutIUJArticle();
      case 'access-transport':
        return const _AccessTransportArticle();
      case 'admissions-overview':
        return const _AdmissionsArticle();
      case 'research-centers':
        return const _ResearchCentersArticle();

      default:
        return Text('Content for "$id" is not yet available.', style: const TextStyle(color: AppColors.textSecondary));
    }
  }

  void _showSuggestEdit(BuildContext context) {
    bool submitted = false;
    AppModal.show(
      context,
      title: 'Suggest an Edit',
      child: StatefulBuilder(
        builder: (ctx, setState) => submitted
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 48),
                  SizedBox(height: 12),
                  Text('Submitted for Moderation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('Your suggestion is pending review.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Describe your suggested changes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () => setState(() => submitted = true),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Content widgets ────────────────────────────────────────────────────────

class _CoursesCategory extends StatelessWidget {
  final BuildContext context;
  const _CoursesCategory({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Access official syllabi, learning objectives, and materials for courses offered at GSIM and GSIR.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        // RBAC notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role-Based Access Restriction', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF92400E), fontSize: 13)),
                    SizedBox(height: 4),
                    Text(
                      'Directly adding or publishing new course entries is strictly limited to Professors and OAA Administrators. Students may only use "Suggest Edit".',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('GSIM — Graduate School of International Management', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ...[
          ('subcategory-finance', 'Finance', AppColors.primaryLight, AppColors.primary),
          ('subcategory-it-operations', 'IT & Operations', const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
          ('subcategory-general-management', 'General Management', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
        ].map((item) => _subcategoryTile(ctx, item.$1, item.$2, item.$3, item.$4)),
        const SizedBox(height: 16),
        const Text('GSIR — Graduate School of International Relations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ...[
          ('subcategory-intl-relations', 'International Relations', const Color(0xFFFDF2F8), const Color(0xFF9333EA)),
          ('subcategory-intl-development', 'International Development', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
          ('subcategory-public-management', 'Public Management & Policy', const Color(0xFFF0FDF4), const Color(0xFF15803D)),
        ].map((item) => _subcategoryTile(ctx, item.$1, item.$2, item.$3, item.$4)),
      ],
    );
  }

  Widget _subcategoryTile(BuildContext ctx, String id, String label, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HoverCard(
        onTap: () => ctx.go('/wiki/$id'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.book_outlined, color: fg, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryPage extends StatelessWidget {
  final String description;
  final List<(String, String)> courses;
  final BuildContext context;
  final String? emptyMessage;

  const _SubcategoryPage({
    required this.description,
    required this.courses,
    required this.context,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        if (courses.isEmpty && emptyMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_empty, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(emptyMessage!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              ],
            ),
          )
        else
          ...courses.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HoverCard(
              onTap: () => ctx.go('/wiki/${c.$1}'),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(c.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF312E81))),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          )),
      ],
    );
  }
}

class _ResidentialLifeCategory extends StatelessWidget {
  final BuildContext context;
  const _ResidentialLifeCategory({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final pages = [
      (Icons.ac_unit_outlined, const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'Winter Survival Guide', 'winter-survival'),
      (Icons.delete_outline, const Color(0xFFDCFCE7), const Color(0xFF16A34A), 'Trash Separation Mastery', 'trash-mastery'),
      (Icons.location_on_outlined, AppColors.primaryLight, AppColors.primary, 'Urasa Station Transit Guide', 'urasa-station'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Everything you need to know about living on campus.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...pages.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: HoverCard(
            onTap: () => ctx.go('/wiki/${p.$5}'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.$2, borderRadius: BorderRadius.circular(8)), child: Icon(p.$1, color: p.$3, size: 18)),
                const SizedBox(width: 12),
                Text(p.$4, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _AcademicsCategory extends StatelessWidget {
  final BuildContext context;
  const _AcademicsCategory({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Guides on academic procedures, calendar synchronization, and cross-registration.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        HoverCard(
          onTap: () => ctx.go('/wiki/device-calendar'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: const Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Syncing Timetable & Reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaceholderCategory extends StatelessWidget {
  final IconData icon;
  final String message;
  const _PlaceholderCategory({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(icon, size: 56, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CourseArticle extends StatelessWidget {
  final String instructor;
  final String schedule;
  final String credits;
  final String description;
  final String objective;
  final String objectiveLabel;

  const _CourseArticle({
    required this.instructor,
    required this.schedule,
    required this.credits,
    required this.description,
    required this.objective,
    required this.objectiveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaRow(instructor, schedule, credits),
        const SizedBox(height: 20),
        _sectionTitle('Course Description'),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        _sectionTitle(objectiveLabel),
        const SizedBox(height: 8),
        Text(objective, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _CourseArticleWithList extends StatelessWidget {
  final String instructor;
  final String schedule;
  final String credits;
  final String description;
  final String listLabel;
  final List<String> listItems;

  const _CourseArticleWithList({
    required this.instructor,
    required this.schedule,
    required this.credits,
    required this.description,
    required this.listLabel,
    required this.listItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaRow(instructor, schedule, credits),
        const SizedBox(height: 20),
        _sectionTitle('Course Description'),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        _sectionTitle(listLabel),
        const SizedBox(height: 8),
        ...listItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
            ],
          ),
        )),
      ],
    );
  }
}

Widget _metaRow(String instructor, String schedule, String credits) {
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      _MetaChip(label: 'Instructor', value: instructor),
      _MetaChip(label: 'Schedule', value: schedule),
      _MetaChip(label: 'Credits', value: credits),
    ],
  );
}

Widget _sectionTitle(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const Divider(),
    ],
  );
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF818CF8), letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF312E81))),
        ],
      ),
    );
  }
}

// ── Article content widgets ────────────────────────────────────────────────

class _WinterSurvivalArticle extends StatelessWidget {
  const _WinterSurvivalArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minamiuonuma is located in "Snow Country" (Yukiguni). Winters here are exceptionally beautiful but require serious preparation. Snow can exceed 2-3 meters at its peak.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        _sectionTitle('1. Essential Clothing'),
        const SizedBox(height: 8),
        ...[
          ('Snow Boots', 'Do not rely on regular sneakers. Buy tall, waterproof snow boots with deep treads.'),
          ('Layering', 'Heattech (from Uniqlo) is highly recommended. Always wear a thermal base layer.'),
          ('Outerwear', 'A waterproof, windproof jacket is mandatory.'),
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
              Expanded(child: RichText(text: TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                children: [
                  TextSpan(text: '${item.$1}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: item.$2),
                ],
              ))),
            ],
          ),
        )),
        const SizedBox(height: 20),
        _sectionTitle('2. Dorm Heating & Utilities'),
        const SizedBox(height: 8),
        const Text(
          'Your room\'s AC unit functions as a heater. Use the timer function to turn on the heat 30 minutes before you wake up.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: Color(0xFFFBBF24), width: 4)),
          ),
          child: const Text(
            '⚠️ Emergency Tip: Keep a physical shovel in your room or car. You may need to dig your way out of the parking lot after heavy overnight snowfall!',
            style: TextStyle(fontSize: 13, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _TrashMasteryArticle extends StatelessWidget {
  const _TrashMasteryArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Japan has strict garbage sorting rules, and Minamiuonuma is no exception. Proper separation in the dormitories (like SD1) is mandatory.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Burnable (Moeru Gomi)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
                    SizedBox(height: 4),
                    Text('Use the designated RED local bags. Includes food waste, paper that can\'t be recycled, and small plastics.', style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Non-Burnable (Moenai Gomi)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                    SizedBox(height: 4),
                    Text('Use the designated BLUE local bags. Includes ceramics, glass, metals, and hard plastics.', style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('PET Bottles & Cans'),
        const SizedBox(height: 8),
        const Text(
          'Caps and labels must be removed from PET bottles. Rinse all cans and bottles before placing them in the designated dorm bins.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _UrasaStationArticle extends StatelessWidget {
  const _UrasaStationArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urasa Station is our primary gateway to Tokyo (via the Joetsu Shinkansen) and neighboring towns.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Shuttle Bus Schedule'),
        const SizedBox(height: 8),
        const Text('The IUJ shuttle runs daily between campus and Urasa Station. The ride takes approximately 10-15 minutes.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...[
          ('Morning Peak', '07:30, 08:15, 08:50'),
          ('Afternoon', '12:30, 14:00, 16:30'),
          ('Evening', '18:15, 20:00 (Last bus)'),
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Row(
            children: [
              const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
              RichText(text: TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                children: [
                  TextSpan(text: '${item.$1}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: item.$2),
                ],
              )),
            ],
          ),
        )),
        const SizedBox(height: 8),
        const Text('* Schedules are subject to change during holidays and heavy snow days.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class _DeviceCalendarArticle extends StatelessWidget {
  const _DeviceCalendarArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Missing classes or assignment deadlines is easy if your schedule isn\'t synced directly to your personal device.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Device Calendar Integration'),
        const SizedBox(height: 8),
        const Text(
          'For all students, we highly recommend integrating your IUJ schedule directly into your native device calendar for the most reliable notifications.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('The "10-30-60" Rule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF312E81))),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'When syncing via the MyIUJ! app to your device, the system automatically generates three cascading reminders:',
                style: TextStyle(fontSize: 13, color: Color(0xFF312E81)),
              ),
              const SizedBox(height: 8),
              ...['1 Hour before (Get ready / Review notes)', '30 Minutes before (Leave dorm / Walk to main building)', '10 Minutes before (Find your seat)']
                  .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Row(children: [
                      const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF312E81), fontWeight: FontWeight.w500)),
                    ]),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('How it Works'),
        const SizedBox(height: 8),
        const Text(
          'Because MyIUJ! uses your Google Workspace SSO, your timetable is automatically synced to your device\'s primary calendar. No manual setup is required.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Administration category ─────────────────────────────────────────────────

class _AdminCategory extends StatelessWidget {
  final BuildContext context;
  const _AdminCategory({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final pages = [
      ('about-iuj', Icons.info_outline, 'About IUJ', 'History, mission, and key facts about IUJ.'),
      ('access-transport', Icons.train_outlined, 'Getting to Campus', 'Urasa Station, Shinkansen, shuttle schedule.'),
      ('admissions-overview', Icons.school_outlined, 'Admissions Overview', 'Deadlines, requirements, and application steps.'),
      ('research-centers', Icons.science_outlined, 'Research Centers', 'GLOCOM, Case Center, Research Institute.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pages.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: HoverCard(
          onTap: () => ctx.go('/wiki/${p.$1}'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: Icon(p.$2, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$3, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(p.$4, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

// ── About IUJ ───────────────────────────────────────────────────────────────

class _AboutIUJArticle extends StatelessWidget {
  const _AboutIUJArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Overview'),
        const SizedBox(height: 8),
        const Text(
          'The International University of Japan (IUJ) was established in 1982 in Minami-Uonuma, Niigata, following strong support from leaders in Japan\'s business and academic communities. It was founded with a clear purpose: to develop highly skilled professionals capable of active engagement in the global arena.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Key Facts'),
        const SizedBox(height: 8),
        ...[
          ('Japan\'s first all-English graduate university', 'IUJ was the first graduate-level university in Japan to offer all programs entirely in English.'),
          ('60+ nationalities', 'Students from over 60 countries study together on a fully residential campus, creating one of Japan\'s most internationally diverse graduate communities.'),
          ('Small class sizes', 'Low faculty-to-student ratios enable close mentorship and direct engagement with professors.'),
          ('Fully residential', 'All students live on campus in Minami-Uonuma — a model that fosters deep intercultural exchange outside the classroom.'),
          ('~50% international faculty', 'Approximately half the faculty are from overseas, bringing a genuinely global perspective to teaching and research.'),
        ].map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 5), child: Icon(Icons.circle, size: 6, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    children: [
                      TextSpan(text: '${f.$1}  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: f.$2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 20),
        _sectionTitle('Graduate Schools'),
        const SizedBox(height: 8),
        ...[
          ('GSIR', 'Graduate School of International Relations — MA and PhD programs in International Relations, International Development, and Public Management & Policy.'),
          ('GSIM', 'Graduate School of International Management — MBA, Intensive MBA, Digital Transformation Program (DXP), and International Social Entrepreneurship Program (ISEP).'),
          ('CLEAR', 'Center for Language Education and Research — English and Japanese language programs supporting all students.'),
        ].map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                children: [
                  TextSpan(text: '${s.$1}  ', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  TextSpan(text: s.$2),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ── Access & Transport ──────────────────────────────────────────────────────

class _AccessTransportArticle extends StatelessWidget {
  const _AccessTransportArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '777 Kokusai-cho, Minami Uonuma-shi, Niigata 949-7277, Japan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF312E81)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('From Tokyo — by Shinkansen'),
        const SizedBox(height: 8),
        const Text(
          'Take the Joetsu Shinkansen (Toki SuperExpress) from Tokyo Station to Urasa Station. The journey is approximately 90 minutes. Trains run frequently throughout the day.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('From Niigata City'),
        const SizedBox(height: 8),
        const Text(
          'Take the Joetsu Shinkansen from Niigata Station to Urasa Station — approximately 40 minutes.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Urasa Station → Campus (IUJ Shuttle)'),
        const SizedBox(height: 8),
        const Text(
          'A free IUJ shuttle bus runs between Urasa Station and campus. The ride takes approximately 10 minutes.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFDE68A))),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shuttle operates hourly, 8:00 AM – 8:00 PM on weekdays. Check OSS for weekend/holiday schedules.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('By Car'),
        const SizedBox(height: 8),
        const Text(
          'Use the Kanetsu Expressway, exiting at Muikamachi or Koide. Follow Route 17 toward Urasa Station. Approx. 3.5 hours from Tokyo, 1.5 hours from Niigata City.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Tokyo Liaison Office'),
        const SizedBox(height: 8),
        const Text(
          'Harks Roppongi Building, 2nd Floor, Roppongi. Accessible via the Hibiya Line or Oedo Line (Roppongi Station).',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
      ],
    );
  }
}

// ── Admissions Overview ─────────────────────────────────────────────────────

class _AdmissionsArticle extends StatelessWidget {
  const _AdmissionsArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IUJ admits students annually for a September intake. Applications are submitted through the IUJ Online Application System.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Application Deadlines (September 2026 Entry)'),
        const SizedBox(height: 10),
        _deadlineTable(),
        const SizedBox(height: 20),
        _sectionTitle('GSIM-Specific Requirements'),
        const SizedBox(height: 8),
        const Text(
          'GSIM applicants must provide either official GMAT or GRE scores, or complete the institution\'s own math assessment.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('English Language Proficiency'),
        const SizedBox(height: 8),
        const Text(
          'Applicants are exempt from the English requirement if they were educated for at least four years in an English-speaking country (Australia, Canada, Ireland, New Zealand, UK, USA) or completed a degree at an English-medium institution with supporting documentation.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Scholarships & Financial Support'),
        const SizedBox(height: 8),
        const Text(
          'IUJ offers generous financial support including the fully funded Sohei Nakayama Memorial Scholarship. A substantial majority of students receive government or corporate sponsorships. Use the scholarship search tool on the IUJ admissions page to find applicable funding.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
          child: const Row(
            children: [
              Icon(Icons.mail_outline, color: Color(0xFF15803D), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contact admissions@iuj.ac.jp for inquiries about requirements, visas, or special accommodation needs.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF14532D)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deadlineTable() {
    final rows = [
      ('Master\'s — International', 'Dec 10, 2025', 'Feb 12, 2026', 'Apr 15, 2026'),
      ('PhD Programs', 'Nov 17, 2025', 'Feb 17, 2026', 'Apr 17, 2026'),
    ];
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Program', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Text('1st', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Text('2nd', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Text('3rd', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              ],
            ),
          ),
          ...rows.map((r) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(r.$1, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text(r.$3, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text(r.$4, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Research Centers ────────────────────────────────────────────────────────

class _ResearchCentersArticle extends StatelessWidget {
  const _ResearchCentersArticle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IUJ supports academic research through several dedicated centers and institutes. Students can access these resources through the Research section on the IUJ website.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 20),
        ...[
          ('Research Institute', Icons.hub_outlined, 'Manages grants, publications, and institutional research support. Maintains an archive of research initiatives and oversees research compliance and ethics guidelines.'),
          ('GLOCOM', Icons.public_outlined, 'A separate research center focused on globalization and communications research. Accessible via glocom.org.'),
          ('Case Center', Icons.cases_outlined, 'Dedicated facility for developing and analyzing real-world business case studies. Used extensively in GSIM teaching.'),
          ('Researchers Information Database', Icons.manage_search_outlined, 'Searchable portal mapping faculty and researcher expertise across IUJ. Available at rmap.iuj.ac.jp.'),
          ('Matsushita Library (MLIC)', Icons.local_library_outlined, 'The main campus library providing comprehensive academic resources, journal databases, and study spaces. Contact: library@iuj.ac.jp  |  Ext. 4333.'),
        ].map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: Icon(r.$2, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(r.$3, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
