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
  String _comment = '';
  final _commentCtrl = TextEditingController();

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
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _step / 4,
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 16),
        if (_step == 1) _locationStep(),
        if (_step == 2) _issueStep(),
        if (_step == 3) _specificStep(),
        if (_step == 4) _commentsStep(),
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
              child: Text(_stepLabel),
            ),
          ],
        ),
      ],
    );
  }

  String get _stepLabel {
    if (_step == 4) return _comment.isEmpty ? 'Skip' : 'Next';
    return 'Next';
  }

  bool get _canContinue {
    return switch (_step) {
      1 => _where != null,
      2 => _what != null,
      3 => _specify != null,
      _ => true,
    };
  }

  Widget _locationStep() {
    return DropdownMenu<String>(
      initialSelection: _where,
      label: const Text('Where is the issue?'),
      expandedInsets: EdgeInsets.zero,
      menuStyle: const MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
      ),
      dropdownMenuEntries: _locations
          .map((l) => DropdownMenuEntry(value: l, label: l))
          .toList(),
      onSelected: (value) => setState(() {
        _where = value;
        _what = null;
        _specify = null;
      }),
    );
  }

  Widget _issueStep() {
    final issues = _issuesByLocation[_where] ?? const <String>[];
    return DropdownMenu<String>(
      initialSelection: _what,
      label: const Text('What is affected?'),
      expandedInsets: EdgeInsets.zero,
      menuStyle: const MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
      ),
      dropdownMenuEntries: issues
          .map((issue) => DropdownMenuEntry(value: issue, label: issue))
          .toList(),
      onSelected: (value) => setState(() {
        _what = value;
        _specify = null;
      }),
    );
  }

  Widget _specificStep() {
    final specifics = _specificsByIssue[_what] ?? const <String>[];
    return DropdownMenu<String>(
      initialSelection: _specify,
      label: const Text('Specify the problem'),
      expandedInsets: EdgeInsets.zero,
      menuStyle: const MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
      ),
      dropdownMenuEntries: specifics
          .map((item) => DropdownMenuEntry(value: item, label: item))
          .toList(),
      onSelected: (value) => setState(() => _specify = value),
    );
  }

  Widget _commentsStep() {
    return TextField(
      controller: _commentCtrl,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Any additional details? (optional)',
        border: OutlineInputBorder(),
      ),
      onChanged: (v) => setState(() => _comment = v),
    );
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
      return;
    }
    Navigator.of(context).pop(true);
    widget.onSubmitted?.call();
  }
}
