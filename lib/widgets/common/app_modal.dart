import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable modal constrained to max-width 448px (Tailwind max-w-md equivalent)
class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppModal(title: title, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
              if (actions != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
