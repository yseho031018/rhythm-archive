import 'package:flutter/material.dart';

Future<String?> showSummaryEditor(
  BuildContext context, {
  required String initialValue,
}) async {
  final controller = TextEditingController(text: initialValue);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('오늘의 한 줄 수정'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 70,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: '오늘을 기억할 한 줄을 적어보세요.',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: const Text('적용'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
