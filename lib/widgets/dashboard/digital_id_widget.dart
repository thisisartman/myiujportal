import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../common/dashboard_card.dart';
import '../profile/digital_id_card.dart';

class DigitalIdWidget extends StatelessWidget {
  const DigitalIdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final student = kMockStudentInfo;
    return DashboardCard(
      label: const DashboardCardLabel(
        icon: Icons.badge_outlined,
        text: 'Digital ID',
      ),
      actionLabel: 'Profile',
      onAction: () => _showLargeId(context, student),
      child: GestureDetector(
        onTap: () => _showLargeId(context, student),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.ruleSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 4, color: AppColors.primary),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'International University of Japan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          student.studentId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 28,
                      child: CustomPaint(
                        painter: Code128Painter(data: student.studentId),
                        size: Size.infinite,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MetaCell(label: 'Program', value: student.program),
                        _MetaCell(label: 'Cohort', value: student.cohort),
                        _MetaCell(label: 'Dorm', value: student.dorm),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Text(
                          'Valid · Spring 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Tap to enlarge',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLargeId(BuildContext context, MockStudentInfo student) {
    AppModal.show(
      context,
      title: 'Digital ID',
      child: _IdEnlargeModal(student: student),
    );
  }
}

class _MetaCell extends StatelessWidget {
  final String label;
  final String value;

  const _MetaCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdEnlargeModal extends StatelessWidget {
  final MockStudentInfo student;

  const _IdEnlargeModal({required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 72,
          width: double.infinity,
          child: CustomPaint(
            painter: Code128Painter(data: student.studentId),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          student.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          student.email,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        _DetailRow(label: 'Student ID', value: student.studentId),
        _DetailRow(label: 'Program', value: student.program),
        _DetailRow(label: 'Cohort', value: student.cohort),
        _DetailRow(label: 'Dorm', value: student.dorm),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
