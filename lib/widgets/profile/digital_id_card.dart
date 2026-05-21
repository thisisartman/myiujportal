import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DigitalIdCard extends StatelessWidget {
  final String studentName;
  final String studentId;

  const DigitalIdCard({
    super.key,
    this.studentName = 'Apoorv Terwadkar',
    this.studentId = 'IUJ-2026-0001',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: IUJ branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'IUJ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Student ID Card',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Student name
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
          const SizedBox(height: 3),
          Text(
            studentId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          // Code128 barcode
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: Code128Painter(data: studentId),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            studentId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Code128B encoder ──────────────────────────────────────────────────────────

class Code128Painter extends CustomPainter {
  final String data;

  const Code128Painter({required this.data});

  // Code128 symbol patterns indexed by symbol value (0–102).
  // Each string is 6 digits: bar-space-bar-space-bar-space widths.
  static const _kPatterns = [
    '212222', '222122', '222221', '121223', '121322', '131222', '122213',
    '122312', '132212', '221213', '221312', '231212', '112232', '122132',
    '122231', '113222', '123122', '123221', '223211', '221132', '221231',
    '213212', '223112', '312131', '311222', '321122', '321221', '312212',
    '322112', '322211', '212123', '212321', '232121', '111323', '131123',
    '131321', '112313', '132113', '132311', '211313', '231113', '231311',
    '112133', '112331', '132131', '113123', '113321', '133121', '313121',
    '211331', '231131', '213113', '213311', '213131', '311123', '311321',
    '331121', '312113', '312311', '332111', '314111', '221411', '431111',
    '111224', '111422', '121124', '121421', '141122', '141221', '112214',
    '112412', '122114', '122411', '142112', '142211', '241211', '221114',
    '413111', '241112', '134111', '111242', '121142', '121241', '114212',
    '124112', '124211', '411212', '421112', '421211', '212141', '214121',
    '412121', '111143', '111341', '131141', '114113', '114311', '411113',
    '411311', '113141', '114131', '311141', '411131',
  ];
  static const _kStartB = '211214'; // symbol value 104
  static const _kStop   = '2331112'; // 7-element stop bar

  List<int> _buildModules() {
    final modules = <int>[];

    void addPattern(String p) {
      for (final c in p.codeUnits) {
        modules.add(c - 48); // '0'.codeUnit == 48
      }
    }

    addPattern(_kStartB);

    int checksum = 104;
    for (int i = 0; i < data.length; i++) {
      final value = data.codeUnitAt(i) - 32;
      if (value < 0 || value > 95) continue;
      checksum += (i + 1) * value;
      addPattern(_kPatterns[value]);
    }

    addPattern(_kPatterns[checksum % 103]);
    addPattern(_kStop);

    return modules;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final modules = _buildModules();
    final totalUnits = modules.fold(0, (s, m) => s + m);
    if (totalUnits == 0) return;

    final unitPx = size.width / totalUnits;
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..isAntiAlias = false;

    double x = 0;
    bool bar = true;
    for (final w in modules) {
      if (bar) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, w * unitPx, size.height),
          paint,
        );
      }
      x += w * unitPx;
      bar = !bar;
    }
  }

  @override
  bool shouldRepaint(covariant Code128Painter old) => old.data != data;
}
