import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/reports/presentation/reports_screen.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: ReportsScreen());
  }

  group('ReportsScreen', () {
    testWidgets('given reports page, '
        'then shows pie chart', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('given reports page, '
        'then shows category detail list', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('飲食'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
    });

    testWidgets('given reports page, '
        'then shows percentage for categories', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('given reports page, '
        'then shows page title', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('報表'), findsOneWidget);
    });
  });
}
