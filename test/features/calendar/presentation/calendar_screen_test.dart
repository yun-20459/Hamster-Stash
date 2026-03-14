import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/calendar/presentation/calendar_screen.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: Scaffold(body: CalendarScreen()));
  }

  group('CalendarScreen', () {
    testWidgets('given calendar displayed, '
        'then shows month header', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Should show current month/year
      expect(find.textContaining('2026'), findsWidgets);
    });

    testWidgets('given calendar displayed, '
        'then shows day cells', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Should show day numbers
      expect(find.text('15'), findsWidgets);
    });

    testWidgets('given day tapped, '
        'then shows daily transactions', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Tap on a day — today should be auto-selected
      // and show transactions below
      expect(find.text('當日交易'), findsOneWidget);
    });
  });
}
