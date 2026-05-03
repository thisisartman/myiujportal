import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../common/toast_overlay.dart';
import '../profile/issue_report_modal.dart';

class ProfileChip extends ConsumerStatefulWidget {
  const ProfileChip({super.key});

  @override
  ConsumerState<ProfileChip> createState() => _ProfileChipState();
}

class _ProfileChipState extends ConsumerState<ProfileChip> {
  final _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _hovering = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        key: _key,
        onTap: _toggleOverlay,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovering ? AppColors.primary : AppColors.border,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Student',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: offset.dx + size.width - 240,
            top: offset.dy + size.height + 4,
            width: 240,
            child: Material(
              color: Colors.transparent,
              child: _DropdownCard(
                onReportIssue: _openIssueReport,
                onProfile: () {
                  _removeOverlay();
                  context.go('/profile');
                },
                onSignOut: () {
                  _removeOverlay();
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _openIssueReport() async {
    _removeOverlay();
    final submitted = await AppModal.show<bool>(
      context,
      title: 'Report an Issue',
      child: const IssueReportModal(),
    );
    if (!mounted || submitted != true) return;
    showToast(context, 'Report submitted.', type: ToastType.success);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _DropdownCard extends StatelessWidget {
  final VoidCallback onReportIssue;
  final VoidCallback onProfile;
  final VoidCallback onSignOut;

  const _DropdownCard({
    required this.onReportIssue,
    required this.onProfile,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'student@iuj.ac.jp',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _DropdownRow(
            icon: Icons.report_problem_outlined,
            label: 'Report an issue',
            onTap: onReportIssue,
          ),
          _DropdownRow(
            icon: Icons.person_outline,
            label: 'Profile page',
            onTap: onProfile,
          ),
          _DropdownRow(
            icon: Icons.logout,
            label: 'Sign out',
            isDanger: true,
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDanger;
  final VoidCallback onTap;

  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_DropdownRow> createState() => _DropdownRowState();
}

class _DropdownRowState extends State<_DropdownRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDanger ? AppColors.danger : AppColors.textPrimary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          color: _hovering ? AppColors.primaryLight : Colors.transparent,
          child: Row(
            children: [
              Icon(widget.icon, size: 17, color: color),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
