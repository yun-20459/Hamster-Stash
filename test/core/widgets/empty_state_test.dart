import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('given no transactions, '
        'then shows hamster emoji', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(type: EmptyStateType.transactions)),
        ),
      );

      expect(find.text('\u{1F439}'), findsOneWidget);
    });

    testWidgets('given no transactions, '
        'then shows call-to-action text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(type: EmptyStateType.transactions)),
        ),
      );

      expect(find.text('還沒有交易紀錄'), findsOneWidget);
      expect(find.text('來記第一筆帳吧！'), findsOneWidget);
    });

    testWidgets('given no accounts, '
        'then shows accounts message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(type: EmptyStateType.accounts)),
        ),
      );

      expect(find.text('還沒有帳戶'), findsOneWidget);
    });

    testWidgets('given no categories, '
        'then shows categories message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(type: EmptyStateType.categories)),
        ),
      );

      expect(find.text('還沒有分類'), findsOneWidget);
    });

    testWidgets('given no budget, '
        'then shows budget message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(type: EmptyStateType.budget)),
        ),
      );

      expect(find.text('還沒有預算'), findsOneWidget);
    });
  });
}
