import 'package:flutter/material.dart';

import 'harutalk_ui.dart';
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
    final colors = context.colors;
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
                          color: index <= step ? colors.primary : colors.border,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ToriMascot(expression: expression, size: compact ? 92 : 110),
                SizedBox(width: compact ? 8 : 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 14 : 17,
                      14,
                      compact ? 14 : 17,
                      15,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cream,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
