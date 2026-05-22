import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/wiki_pages.dart';
import '../../data/mock_data.dart' show kFacilities;
import '../../models/facility.dart';
import '../../models/wiki_page.dart';
import '../../providers/auth_provider.dart';
import '../../services/wiki_content_service.dart';
import '../../widgets/common/app_modal.dart';
import '../../widgets/common/page_chrome.dart';
import '../../widgets/facilities/booking_modal.dart';
import '../../theme/app_colors.dart';

class WikiArticlePage extends ConsumerWidget {
  final String articleId;
  const WikiArticlePage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = kWikiPages[articleId];
    final role = ref.watch(userRoleProvider);
    final roleSlug = _roleSlug(role);

    if (page == null) {
      return _notFound(context, articleId);
    }

    final bookable = _bookableFacility(page);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Breadcrumb(page: page),
        const SizedBox(height: 14),
        PageGreeting(
          title: page.title,
          meta: [
            MetaText('Updated: ${page.lastUpdated}'),
            const MetaDot(),
            MetaText(_ownerLabel(page.ownerRole), emphasis: true),
          ],
          actions: _actionButtons(context, ref, page, roleSlug),
        ),
        if (bookable != null) ...[
          const SizedBox(height: 16),
          _BookSpaceBanner(facility: bookable),
        ],
        const SizedBox(height: 20),
        _ArticleBody(page: page),
      ],
    );
  }

  Widget _actionButtons(
    BuildContext context,
    WidgetRef ref,
    WikiPage page,
    String roleSlug,
  ) {
    final canEdit = page.canEdit(roleSlug);
    final canSuggest = page.canSuggest(roleSlug);
    if (!canEdit && !canSuggest) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (canEdit)
          ElevatedButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Article'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showEditModal(context, page),
          ),
        if (canSuggest)
          OutlinedButton.icon(
            icon: const Icon(Icons.rate_review_outlined, size: 16),
            label: const Text('Suggest Edit'),
            onPressed: () => _showSuggestModal(context, page),
          ),
      ],
    );
  }

  void _showEditModal(BuildContext context, WikiPage page) {
    final controller = TextEditingController();
    bool saved = false;
    AppModal.show(
      context,
      title: 'Edit: ${page.title}',
      child: StatefulBuilder(
        builder: (ctx, setState) {
          if (saved) {
            return const _SuccessState(
              icon: Icons.check_circle,
              color: AppColors.primary,
              title: 'Changes Published',
              subtitle: 'Your edits are now live.',
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RbacBadge(
                label: 'You have publish access to this article.',
                color: AppColors.primary,
                bgColor: AppColors.primaryLight,
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Edit content (Markdown)',
                  border: OutlineInputBorder(),
                  hintText: '## Section\n\nYour content here…',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => saved = true),
                    child: const Text('Publish'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuggestModal(BuildContext context, WikiPage page) {
    final controller = TextEditingController();
    bool submitted = false;
    AppModal.show(
      context,
      title: 'Suggest Edit: ${page.title}',
      child: StatefulBuilder(
        builder: (ctx, setState) {
          if (submitted) {
            return const _SuccessState(
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              title: 'Submitted for Moderation',
              subtitle: 'Your suggestion will be reviewed by the article owner.',
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RbacBadge(
                label:
                    'Student submissions are queued for moderation. Only authorised staff can publish directly.',
                color: AppColors.warning,
                bgColor: AppColors.warningLight,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Suggested change (Markdown or plain text)',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the change or paste corrected content…',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => submitted = true),
                    child: const Text('Submit for Review'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _notFound(BuildContext context, String id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Not Found',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('No article with id "$id" exists.',
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/wiki'),
          child: const Text('Back to Wiki Home'),
        ),
      ],
    );
  }

  String _roleSlug(UserRole role) => switch (role) {
        UserRole.admin => 'admin',
        UserRole.faculty => 'faculty',
        UserRole.student => 'student',
      };

  String _ownerLabel(String ownerRole) => switch (ownerRole) {
        'faculty-gsim' => 'GSIM Faculty',
        'faculty-gsir' => 'GSIR Faculty',
        'faculty' => 'Faculty',
        'library-staff' => 'Library Staff',
        'student-body' => 'Student Body',
        _ => 'Administration',
      };

  Facility? _bookableFacility(WikiPage page) {
    final t = page.title.toLowerCase();
    if (t.contains('gymnasium') || t.contains('gym') || t.contains('sport hall')) {
      return kFacilities.firstWhere((f) => f.id == 'f7', orElse: () => kFacilities.first);
    }
    if (t.contains('bbq')) {
      return kFacilities.firstWhere((f) => f.id == 'f5', orElse: () => kFacilities.first);
    }
    if (t.contains('student lounge') || t.contains('cnp b1')) {
      return kFacilities.firstWhere((f) => f.id == 'f6', orElse: () => kFacilities.first);
    }
    if (t.contains('lounge')) {
      return kFacilities.firstWhere((f) => f.id == 'f4', orElse: () => kFacilities.first);
    }
    if (t.contains('seminar room')) {
      return kFacilities.firstWhere((f) => f.id == 'f3', orElse: () => kFacilities.first);
    }
    if (t.contains('classroom')) {
      return kFacilities.firstWhere((f) => f.id == 'f1', orElse: () => kFacilities.first);
    }
    if (t.contains('library') || t.contains('mlic') || t.contains('study room')) {
      return kFacilities.firstWhere((f) => f.id == 'f1', orElse: () => kFacilities.first);
    }
    return null;
  }
}

// Book space banner
class _BookSpaceBanner extends StatelessWidget {
  final Facility facility;
  const _BookSpaceBanner({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${facility.name} is bookable',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Reserve a time slot via the Facilities portal',
                  style: TextStyle(fontSize: 12, color: AppColors.accentBlue),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => AppModal.show(
              context,
              title: 'Book ${facility.name}',
              child: BookingModal(facility: facility),
            ),
            child: const Text('Book this space →'),
          ),
        ],
      ),
    );
  }
}

// Article body
class _ArticleBody extends ConsumerWidget {
  final WikiPage page;
  const _ArticleBody({required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.assetPath == null) {
      return const Text('No content available.',
          style: TextStyle(color: AppColors.textSecondary));
    }
    final body = ref.watch(wikiArticleBodyProvider(page.assetPath!));
    return body.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e',
          style: const TextStyle(color: AppColors.danger)),
      data: (md) => _MarkdownBody(markdown: md),
    );
  }
}

class _MarkdownBody extends StatelessWidget {
  final String markdown;
  const _MarkdownBody({required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, height: 1.3),
        h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, height: 1.4),
        h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        p: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.65),
        strong: const TextStyle(fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        code: const TextStyle(fontSize: 13, color: AppColors.accentBlue,
            fontFamily: 'monospace'),
        tableHead: const TextStyle(fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        tableBody: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        tableBorder: TableBorder.all(color: AppColors.ruleSoft, width: 1),
      ),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

// Breadcrumb
class _Breadcrumb extends StatelessWidget {
  final WikiPage page;
  const _Breadcrumb({required this.page});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        GestureDetector(
          onTap: () => context.go('/wiki'),
          child: const Text('Wiki',
              style: TextStyle(color: AppColors.primary,
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
        if (page.subcategory != null) ...[
          Text(page.category,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          Text(page.subcategory!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
        ] else ...[
          Text(page.category,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
        ],
        Text(page.title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}

// Shared widgets
class _RbacBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const _RbacBadge({
    required this.label, required this.color,
    required this.bgColor, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(label,
            style: TextStyle(fontSize: 12, color: color))),
      ]),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _SuccessState({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 48),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
