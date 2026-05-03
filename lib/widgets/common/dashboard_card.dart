import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final Widget label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  final bool flushBody;

  const DashboardCard({
    super.key,
    required this.label,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.flushBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ruleSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                label,
                const SizedBox(width: 12),
                const Expanded(child: Divider(color: AppColors.ruleSofter)),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.tealInk,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.ruleSofter),
          Padding(
            padding: flushBody
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class DashboardCardLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const DashboardCardLabel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.tealInk),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.ink2,
          ),
        ),
      ],
    );
  }
}
