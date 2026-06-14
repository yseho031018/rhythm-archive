import 'package:flutter/material.dart';

import '../widgets/harutalk_ui.dart';

Future<String?> showSummaryEditor(
  BuildContext context, {
  required String initialValue,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _SummaryEditorDialog(initialValue: initialValue),
  );
}

/// 한 줄 수정 다이얼로그. TextEditingController를 자기 State에서 소유·해제해
/// 다이얼로그 종료 애니메이션 도중 컨트롤러가 조기 dispose되는 문제를 피한다.
class _SummaryEditorDialog extends StatefulWidget {
  const _SummaryEditorDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_SummaryEditorDialog> createState() => _SummaryEditorDialogState();
}

class _SummaryEditorDialogState extends State<_SummaryEditorDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const HarutalkDialogIcon(icon: Icons.edit_note_rounded),
      title: const Text('오늘의 한 줄 수정'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 70,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: '오늘을 기억할 한 줄을 적어보세요.',
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        HarutalkDialogActions(
          cancelLabel: '취소',
          confirmLabel: '적용',
          onCancel: () => Navigator.pop(context),
          onConfirm: _submit,
        ),
      ],
    );
  }
}
