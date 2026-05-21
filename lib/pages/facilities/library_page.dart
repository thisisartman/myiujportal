import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
            MetaText('MLIC · IUJ Campus', emphasis: true),
          ],
          actions: OutlinedButton.icon(
            onPressed: () => context.go('/facilities'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Facilities'),
          ),
        ),
        const SizedBox(height: 24),
        PageCard(
          header: const PageCardHeader(
            icon: Icons.local_library_outlined,
            title: 'About MLIC',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Matsushita Library and Information Center (MLIC) is the central library of the International University of Japan. It provides access to academic journals, e-databases, research reports, and loan services for students and faculty.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.65),
              ),
              const SizedBox(height: 8),
              const Text(
                'Services include book loans, renewals, interlibrary loans, Bloomberg and Nikkei Telecom access, and dedicated study rooms.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.65),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open MLIC Library →'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse('https://www.iuj.ac.jp/library/');
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
