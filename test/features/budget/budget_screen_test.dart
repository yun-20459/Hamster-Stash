import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/budget/domain/budget_repository.dart';
import 'package:hamster_stash/features/budget/presentation/budget_providers.dart';
import 'package:hamster_stash/features/budget/presentation/budget_screen.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockBudgetRepository mockBudgetRepo;
  late MockTransactionRepository mockTxnRepo;

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockTxnRepo = MockTransactionRepository();
  });

  Widget buildWidget({List<Budget>? budgets}) {
    when(() => mockBudgetRepo.getActive()).thenAnswer(
      (_) async =>
          budgets ??
          [
            Budget()
              ..id = 1
              ..name = '每月生活費'
              ..amount = 10000
              ..period = BudgetPeriod.monthly
              ..startDate = DateTime(2026, 3)
              ..createdAt = DateTime(2026),
          ],
    );
    when(() => mockTxnRepo.getByDateRange(any(), any())).thenAnswer(
      (_) async => [
        Transaction()
          ..id = 1
          ..amount = 3000
          ..type = TransactionType.expense
          ..dateTime = DateTime(2026, 3, 10)
          ..createdAt = DateTime(2026),
        Transaction()
          ..id = 2
          ..amount = 2000
          ..type = TransactionType.expense
          ..dateTime = DateTime(2026, 3, 12)
          ..createdAt = DateTime(2026),
      ],
    );

    return ProviderScope(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(mockBudgetRepo),
        transactionRepositoryProvider.overrideWithValue(mockTxnRepo),
      ],
      child: const MaterialApp(home: BudgetScreen()),
    );
  }

  group('BudgetScreen', () {
    testWidgets('given budgets, then shows budget name', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('每月生活費'), findsOneWidget);
    });

    testWidgets('given budgets, then shows spending info', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('5,000'), findsWidgets);
    });

    testWidgets('given budgets, then shows percentage', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('given budgets, then shows period label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('每月'), findsOneWidget);
    });

    testWidgets('given no budgets, then shows empty message', (tester) async {
      await tester.pumpWidget(buildWidget(budgets: []));
      await tester.pumpAndSettle();

      expect(find.text('尚未設定預算'), findsOneWidget);
    });

    testWidgets('given budget screen, then shows add button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
