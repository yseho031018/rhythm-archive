import 'package:flutter/material.dart';

enum ToriExpression { hello, thinking, writing, complete, sleeping, journal }

class ToriMascot extends StatelessWidget {
  const ToriMascot({
    super.key,
    this.expression = ToriExpression.hello,
    this.size = 72,
  });

  final ToriExpression expression;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = switch (expression) {
      ToriExpression.hello => 'assets/tori/tori_hello.png',
      ToriExpression.thinking => 'assets/tori/tori_thinking.png',
      ToriExpression.writing => 'assets/tori/tori_writing.png',
      ToriExpression.complete => 'assets/tori/tori_complete.png',
      ToriExpression.sleeping => 'assets/tori/tori_sleeping.png',
      ToriExpression.journal => 'assets/tori/tori_journal.png',
    };

    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: '토리',
      ),
    );
  }
}
