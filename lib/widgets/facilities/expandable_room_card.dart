import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/facility.dart';
import '../../providers/facilities_provider.dart';
import '../../theme/app_colors.dart';
import '../common/app_modal.dart';
import '../common/toast_overlay.dart';
import 'booking_form.dart';
import 'booking_slot_selector.dart';

class ExpandableRoomCard extends ConsumerStatefulWidget {
  final Facility facility;

  const ExpandableRoomCard({super.key, required this.facility});

  @override
  ConsumerState<ExpandableRoomCard> createState() => _ExpandableRoomCardState();
}

class _ExpandableRoomCardState extends ConsumerState<ExpandableRoomCard> {
  bool _expanded = false;
  int? _selectedDay;
  Set<String> _selectedSlots = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      firstChild: _card(child: _header()),
      secondChild: _expandedCard(),
      crossFadeState: _expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
    );
  }

  Widget _expandedCard() {
    return _card(
      child: Column(
        children: [
          _header(),
          const Divider(height: 24),
          if (_selectedDay == null)
            _InlineBookingCalendar(
              onDaySelected: (day) => setState(() {
                _selectedDay = day;
                _selectedSlots = {};
              }),
            )
          else
            BookingSlotSelector(
              slots: _effectiveSlots(),
              selectedSlots: _selectedSlots,
              onToggle: (slot) => setState(() {
                _selectedSlots.contains(slot)
                    ? _selectedSlots.remove(slot)
                    : _selectedSlots.add(slot);
              }),
              onBack: () => setState(() {
                _selectedDay = null;
                _selectedSlots = {};
              }),
              onNext: _openBookingDetails,
            ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _header() {
    final facility = widget.facility;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: facility.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.meeting_room_outlined,
                color: facility.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _AuthorityChip(label: facility.authority),
                ],
              ),
            ),
            Icon(
              _expanded ? Icons.expand_less : Icons.chevron_right,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  List<TimeSlot> _effectiveSlots() {
    final booked = ref.watch(bookedSlotsProvider)[widget.facility.id] ?? {};
    return kMockSlots.map((slot) {
      if (booked.contains(slot.time)) {
        return TimeSlot(time: slot.time, available: false);
      }
      return slot;
    }).toList();
  }

  Future<void> _openBookingDetails() async {
    await AppModal.show<void>(
      context,
      title: 'Booking Details',
      child: BookingForm(
        facility: widget.facility,
        category: widget.facility.category,
        selectedDay: _selectedDay!,
        selectedSlots: _selectedSlots,
        onSubmit: (data) {
          Navigator.of(context).pop();
          ref.read(bookedSlotsProvider.notifier).update((state) {
            final updated = Map<String, Set<String>>.from(state);
            updated[widget.facility.id] = {
              ...(state[widget.facility.id] ?? {}),
              ..._selectedSlots,
            };
            return updated;
          });
          _simulateEmail(widget.facility, _selectedDay!, _selectedSlots, data);
          showToast(
            context,
            'Your request has been submitted. You will be notified about the outcome shortly.',
            type: ToastType.success,
          );
          setState(() {
            _expanded = false;
            _selectedDay = null;
            _selectedSlots = {};
          });
        },
      ),
    );
  }

  void _simulateEmail(
    Facility facility,
    int day,
    Set<String> slots,
    Map<String, String> data,
  ) {
    debugPrint('=== BOOKING EMAIL TO ${facility.authority} ===');
    debugPrint(
      'Facility: ${facility.name} | Day: $day | Slots: ${slots.join(", ")}',
    );
    data.forEach((key, value) => debugPrint('  $key: $value'));
  }
}

class _InlineBookingCalendar extends StatelessWidget {
  final void Function(int day) onDaySelected;

  const _InlineBookingCalendar({required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekdayOffset = DateTime(now.year, now.month, 1).weekday - 1;
    final availableDays = kAvailableDaysForMonth(now.year, now.month);
    final cells = <Widget>[
      for (var i = 0; i < firstWeekdayOffset; i++) const SizedBox(),
      for (var day = 1; day <= daysInMonth; day++)
        _InlineDayCell(
          day: day,
          isPast: day <= now.day,
          isAvailable: availableDays.contains(day),
          onTap: () => onDaySelected(day),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            DateFormat('MMMM yyyy').format(now),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: cells,
        ),
      ],
    );
  }
}

class _InlineDayCell extends StatelessWidget {
  final int day;
  final bool isPast;
  final bool isAvailable;
  final VoidCallback onTap;

  const _InlineDayCell({
    required this.day,
    required this.isPast,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = !isPast && isAvailable;
    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: tappable ? onTap : null,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: tappable ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: tappable ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorityChip extends StatelessWidget {
  final String label;

  const _AuthorityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
