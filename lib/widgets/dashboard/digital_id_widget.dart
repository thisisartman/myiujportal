import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class DigitalIdWidget extends StatefulWidget {
  const DigitalIdWidget({super.key});
  @override
  State<DigitalIdWidget> createState() => _DigitalIdWidgetState();
}

class _DigitalIdWidgetState extends State<DigitalIdWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go('/profile'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovering
                  ? [AppColors.primary, const Color(0xFF0F766E)]
                  : [AppColors.primary, const Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('IUJ-2026-0001', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('MBA · GSIM · Class of 2027', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.badge_outlined, color: Colors.white54, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
