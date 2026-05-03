import 'package:flutter/material.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';

typedef BookingFormData = Map<String, String>;

// Demo data marks these lounge fixtures as food-service venues.
const _cateringFacilityIds = {'f4', 'f5'};

class BookingForm extends StatefulWidget {
  final Facility? facility;
  final FacilityCategory category;
  final int? selectedDay;
  final Set<String> selectedSlots;
  final VoidCallback? onBack;
  final void Function(BookingFormData data) onSubmit;

  const BookingForm({
    super.key,
    this.facility,
    required this.category,
    this.selectedDay,
    this.selectedSlots = const {},
    this.onBack,
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
  final _menuCtrl = TextEditingController();
  final _guestCountCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _attendeesCtrl.dispose();
    _setupCtrl.dispose();
    _notesCtrl.dispose();
    _menuCtrl.dispose();
    _guestCountCtrl.dispose();
    super.dispose();
  }

  bool get _isExtendedForm =>
      widget.category == FacilityCategory.lounge ||
      widget.category == FacilityCategory.gymnasium;

  bool get _isFoodVenue => _cateringFacilityIds.contains(widget.facility?.id);

  void _handleSubmit() {
    final data = <String, String>{
      'reason': _reasonCtrl.text,
      if (_isExtendedForm) 'attendees': _attendeesCtrl.text,
      if (_isExtendedForm) 'setup': _setupCtrl.text,
      if (_isExtendedForm) 'notes': _notesCtrl.text,
      if (_isFoodVenue) 'menuFoodType': _menuCtrl.text,
      if (_isFoodVenue) 'guestListCount': _guestCountCtrl.text,
    };
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.selectedDay != null && widget.selectedSlots.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Day ${widget.selectedDay} - ${widget.selectedSlots.join(', ')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _field(
          _reasonCtrl,
          'Reason for Booking',
          'Brief description of your planned use...',
          maxLines: 3,
        ),
        if (_isExtendedForm) ...[
          const SizedBox(height: 12),
          _field(_attendeesCtrl, 'Expected Attendees', 'e.g. 15 students'),
          const SizedBox(height: 12),
          _field(
            _setupCtrl,
            'Setup Requirements',
            'e.g. chairs in a circle, projector, etc.',
          ),
          const SizedBox(height: 12),
          _field(
            _notesCtrl,
            'Additional Notes',
            'Anything else the office should know...',
            maxLines: 3,
          ),
        ],
        if (_isFoodVenue) ...[
          const SizedBox(height: 12),
          _field(
            _menuCtrl,
            'Menu / Food Type',
            'e.g. halal snacks, BBQ set, drinks',
          ),
          const SizedBox(height: 12),
          _field(_guestCountCtrl, 'Guest List Count', 'e.g. 20'),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            if (widget.onBack != null)
              TextButton(onPressed: widget.onBack, child: const Text('Back')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _handleSubmit,
              child: const Text('Confirm & Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
