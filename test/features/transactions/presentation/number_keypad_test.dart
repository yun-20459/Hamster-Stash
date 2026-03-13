import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/transactions/presentation/number_keypad.dart';

void main() {
  Widget buildKeypad({ValueChanged<String>? onInput}) {
    return MaterialApp(
      home: Scaffold(body: NumberKeypad(onInput: onInput ?? (_) {})),
    );
  }

  group('NumberKeypad', () {
    testWidgets('given keypad displayed, '
        'then shows digits 0-9', (tester) async {
      await tester.pumpWidget(buildKeypad());

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('given keypad displayed, '
        'then shows decimal point', (tester) async {
      await tester.pumpWidget(buildKeypad());

      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('given keypad displayed, '
        'then shows arithmetic operators', (tester) async {
      await tester.pumpWidget(buildKeypad());

      expect(find.text('+'), findsOneWidget);
      expect(find.text('\u2212'), findsOneWidget);
      expect(find.text('\u00D7'), findsOneWidget);
      expect(find.text('\u00F7'), findsOneWidget);
    });

    testWidgets('given keypad displayed, '
        'then shows backspace button', (tester) async {
      await tester.pumpWidget(buildKeypad());

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('given digit tapped, '
        'then calls onInput with digit', (tester) async {
      String? tapped;
      await tester.pumpWidget(buildKeypad(onInput: (v) => tapped = v));

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(tapped, '5');
    });
  });
}
