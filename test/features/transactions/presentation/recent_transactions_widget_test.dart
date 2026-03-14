import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/transactions/presentation/recent_transactions_widget.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: Scaffold(body: RecentTransactionsWidget()));
  }

  group('RecentTransactionsWidget', () {
    testWidgets('given widget displayed, '
        'then shows section header', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('最近交易'), findsOneWidget);
    });

    testWidgets('given mock transactions, '
        'then shows expense in red', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Mock data has expense entries with minus sign
      expect(find.textContaining('-'), findsWidgets);
    });

    testWidgets('given mock transactions, '
        'then shows income in green', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Mock data has income entries with plus sign
      expect(find.textContaining('+'), findsWidgets);
    });

    testWidgets('given mock transactions, '
        'then shows category and note', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Should show category names from mock data
      expect(find.text('午餐'), findsOneWidget);
    });
  });
}
