import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PageGreeting extends StatelessWidget {
  final String title;
  final List<Widget> meta;
  final Widget? actions;

  const PageGreeting({
    super.key,
    required this.title,
    this.meta = const [],
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 720;
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: meta,
          ),
        ],
      ],
    );

    if (compact || actions == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          if (actions != null) ...[const SizedBox(height: 14), actions!],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        actions!,
      ],
    );
  }
}

class MetaText extends StatelessWidget {
  final String text;
  final bool emphasis;

  const MetaText(this.text, {super.key, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
        color: emphasis ? AppColors.tealInk : AppColors.textSecondary,
      ),
    );
  }
}

class MetaDot extends StatelessWidget {
  const MetaDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PageCard extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool clip;

  const PageCard({
    super.key,
    required this.child,
    this.header,
    this.padding = const EdgeInsets.all(18),
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ruleSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: header!,
            ),
            const Divider(height: 1, color: AppColors.ruleSofter),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class PageCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? action;

  const PageCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.tealInk),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.ink2,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.ruleSofter)),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class SoftChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  const SoftChip({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgSunken,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.ruleSofter,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPanel extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  const SearchPanel({
    super.key,
    required this.hint,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PageCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.bgSunken,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.ruleSoft),
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 18),
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(height: 12), trailing!],
        ],
      ),
    );
  }
}
