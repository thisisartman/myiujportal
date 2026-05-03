// lib/widgets/common/hover_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A container that darkens its border and background on hover.
/// Wrap any tappable card with this instead of a plain Container.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color hoverColor;
  final Color baseBorderColor;
  final Color hoverBorderColor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.baseColor = Colors.white,
    this.hoverColor = AppColors.primaryLight,
    this.baseBorderColor = AppColors.border,
    this.hoverBorderColor = AppColors.primary,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovering ? widget.hoverColor : widget.baseColor,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _hovering
                  ? widget.hoverBorderColor
                  : widget.baseBorderColor,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
