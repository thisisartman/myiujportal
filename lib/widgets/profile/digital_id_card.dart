import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DigitalIdCard extends StatelessWidget {
  final String studentName;
  final String studentId;

  const DigitalIdCard({
    super.key,
    this.studentName = 'Student',
    this.studentId = 'IUJ-2026-0001',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: BarcodePainter(id: studentId),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            studentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  studentId,
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 0,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Text(
                'IUJ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BarcodePainter extends CustomPainter {
  final String id;

  const BarcodePainter({required this.id});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary;
    var x = 0.0;

    for (final unit in id.codeUnits) {
      final barWidth = (unit % 3) + 1.0;
      if (x > size.width) break;
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + ((unit % 2) + 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) =>
      oldDelegate.id != id;
}
