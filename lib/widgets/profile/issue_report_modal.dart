import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class IssueReportModal extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const IssueReportModal({super.key, this.onSubmitted});

  @override
  State<IssueReportModal> createState() => _IssueReportModalState();
}

class _IssueReportModalState extends State<IssueReportModal> {
  int _step = 1;
  String? _where;
  String? _what;
  String? _specify;

  static const _locations = [
    'Study Room 1',
    'Study Room 2',
    'Library',
    'Gym',
    'Cafeteria',
    'Lobby',
  ];

  static const _issuesByLocation = {
    'Study Room 1': ['Lighting', 'TV', 'AC', 'Projector'],
    'Study Room 2': ['Lighting', 'TV', 'AC', 'Projector'],
    'Library': ['Lighting', 'AC', 'Projector'],
    'Gym': ['Lighting', 'AC'],
    'Cafeteria': ['Lighting', 'AC', 'Fridge'],
    'Lobby': ['Lighting', 'TV', 'AC'],
  };

  static const _specificsByIssue = {
    'Lighting': ['Not turning on', 'Flickering', 'Too dim'],
    'TV': ['Not turning on', 'HDMI not working', 'No sound'],
    'AC': ['Not cooling', 'Not heating', 'Remote missing'],
    'Projector': ['Not turning on', 'HDMI not working', 'Image blurry'],
    'Fridge': ['Not cooling', 'Leaking', 'Door not closing'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _step / 3,
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 16),
        if (_step == 1) _locationStep(),
        if (_step == 2) _issueStep(),
        if (_step == 3) _specificStep(),
        const SizedBox(height: 18),
        Row(
          children: [
            if (_step > 1)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: const Text('Back'),
              ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _canContinue ? _next : null,
              child: Text(_step == 3 ? 'Confirm' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }

  bool get _canContinue {
    return switch (_step) {
      1 => _where != null,
      2 => _what != null,
      _ => _specify != null,
    };
  }

  Widget _locationStep() {
    return DropdownButtonFormField<String>(
      initialValue: _where,
      decoration: const InputDecoration(
        labelText: 'Where is the issue?',
        border: OutlineInputBorder(),
      ),
      items: _locations
          .map(
            (location) =>
                DropdownMenuItem(value: location, child: Text(location)),
          )
          .toList(),
      onChanged: (value) => setState(() {
        _where = value;
        _what = null;
        _specify = null;
      }),
    );
  }

  Widget _issueStep() {
    final issues = _issuesByLocation[_where] ?? const <String>[];
    return DropdownButtonFormField<String>(
      initialValue: _what,
      decoration: const InputDecoration(
        labelText: 'What is affected?',
        border: OutlineInputBorder(),
      ),
      items: issues
          .map((issue) => DropdownMenuItem(value: issue, child: Text(issue)))
          .toList(),
      onChanged: (value) => setState(() {
        _what = value;
        _specify = null;
      }),
    );
  }

  Widget _specificStep() {
    final specifics = _specificsByIssue[_what] ?? const <String>[];
    return DropdownButtonFormField<String>(
      initialValue: _specify,
      decoration: const InputDecoration(
        labelText: 'Specify the problem',
        border: OutlineInputBorder(),
      ),
      items: specifics
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => setState(() => _specify = value),
    );
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    Navigator.of(context).pop(true);
    widget.onSubmitted?.call();
  }
}
