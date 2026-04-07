import 'package:flutter/material.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';

typedef BookingFormData = Map<String, String>;

class BookingForm extends StatefulWidget {
  final FacilityCategory category;
  final VoidCallback onBack;
  final void Function(BookingFormData data) onSubmit;

  const BookingForm({
    super.key,
    required this.category,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _reasonCtrl = TextEditingController();
  final _attendeesCtrl = TextEditingController();
  final _setupCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _attendeesCtrl.dispose();
    _setupCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isExtendedForm =>
      widget.category == FacilityCategory.lounge ||
      widget.category == FacilityCategory.gymnasium;

  void _handleSubmit() {
    final data = <String, String>{
      'reason': _reasonCtrl.text,
      if (_isExtendedForm) 'attendees': _attendeesCtrl.text,
      if (_isExtendedForm) 'setup': _setupCtrl.text,
      if (_isExtendedForm) 'notes': _notesCtrl.text,
    };
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _field(_reasonCtrl, 'Reason for Booking', 'Brief description of your planned use...', maxLines: 3),
        if (_isExtendedForm) ...[
          const SizedBox(height: 12),
          _field(_attendeesCtrl, 'Expected Attendees', 'e.g. 15 students'),
          const SizedBox(height: 12),
          _field(_setupCtrl, 'Setup Requirements', 'e.g. chairs in a circle, projector, etc.'),
          const SizedBox(height: 12),
          _field(_notesCtrl, 'Additional Notes', 'Anything else the office should know...', maxLines: 3),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(onPressed: widget.onBack, child: const Text('Back')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _handleSubmit,
              child: const Text('Confirm & Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
