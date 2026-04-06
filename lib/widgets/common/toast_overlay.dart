import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum ToastType { info, success, error }

void showToast(BuildContext context, String message, {ToastType type = ToastType.info}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 32,
      right: 24,
      child: _ToastCard(message: message, type: type, onDismiss: () => entry.remove()),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), () {
    if (entry.mounted) entry.remove();
  });
}

class _ToastCard extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;
  const _ToastCard({required this.message, required this.type, required this.onDismiss});
  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 200), vsync: this)..forward();
    _slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.type) {
      case ToastType.success: return AppColors.success;
      case ToastType.error: return AppColors.danger;
      case ToastType.info: return AppColors.primary;
    }
  }

  Color get _bgColor {
    switch (widget.type) {
      case ToastType.success: return AppColors.successLight;
      case ToastType.error: return AppColors.dangerLight;
      case ToastType.info: return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.message,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              ),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onDismiss,
                child: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
