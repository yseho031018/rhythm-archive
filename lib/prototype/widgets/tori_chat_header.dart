import 'package:flutter/material.dart';

import 'tori_mascot.dart';

class ToriChatHeader extends StatelessWidget {
  const ToriChatHeader({
    super.key,
    required this.message,
    required this.step,
    required this.totalSteps,
    this.expression = ToriExpression.hello,
    this.onClose,
  });

  final String message;
  final int step;
  final int totalSteps;
  final ToriExpression expression;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClose,
              tooltip: '처음으로',
              icon: const Icon(Icons.close_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  for (var index = 0; index < totalSteps; index++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: EdgeInsets.only(
                          right: index == totalSteps - 1 ? 0 : 7,
                        ),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= step
                              ? const Color(0xFF4B9875)
                              : const Color(0xFFE2ECE6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 42),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToriMascot(expression: expression, size: 84),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: const Color(0xFFEDE6D7)),
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF434A45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
