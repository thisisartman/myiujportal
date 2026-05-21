import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/common/page_chrome.dart';

class CampusDirectoryPage extends StatefulWidget {
  final String? initialQuery;

  const CampusDirectoryPage({super.key, this.initialQuery});

  @override
  State<CampusDirectoryPage> createState() => _CampusDirectoryPageState();
}

class _CampusDirectoryPageState extends State<CampusDirectoryPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery;
    if (q != null && q.isNotEmpty) {
      _controller.text = q;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _launch(q);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _launch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final uri = Uri.parse(
      'https://www2.iuj.ac.jp/directory/?search=${Uri.encodeComponent(q)}',
    );
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _launch(value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageGreeting(
          title: 'Campus Directory',
          meta: const [
            MetaText('Students, faculty, staff and organizations'),
            MetaDot(),
            MetaText('Powered by IUJ Directory', emphasis: true),
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
            icon: Icons.people_outline,
            title: 'Search Directory',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search by name, email, or department. Results open in the IUJ online directory.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onChanged,
                      onSubmitted: _launch,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Name, email, or department…',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.bgSunken,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.ruleSoft),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.ruleSoft),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 15),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    ),
                    onPressed: () => _launch(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
