import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/recent_transactions_widget.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

Transaction _makeTxn({
  double amount = 100,
  TransactionType type = TransactionType.expense,
  String? note,
}) {
  return Transaction()
    ..id = 1
    ..amount = amount
    ..type = type
    ..dateTime = DateTime(2026, 3, 13)
    ..note = note
    ..createdAt = DateTime(2026);
}

void main() {
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
  });

  Widget buildWidget({List<Transaction>? txns}) {
    when(() => mockRepo.getRecent()).thenAnswer(
      (_) async =>
          txns ??
          [
            _makeTxn(note: 'Lunch'),
            _makeTxn(
              note: 'Salary',
              type: TransactionType.income,
              amount: 45000,
            ),
          ],
    );
    return ProviderScope(
      overrides: [transactionRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(
        home: Scaffold(body: RecentTransactionsWidget()),
      ),
    );
  }

  group('RecentTransactionsWidget', () {
    testWidgets('given widget displayed, '
        'then shows section header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('最近交易'), findsOneWidget);
    });

    testWidgets('given transactions, '
        'then shows expense with minus sign', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('-'), findsWidgets);
    });

    testWidgets('given transactions, '
        'then shows income with plus sign', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsWidgets);
    });

    testWidgets('given no transactions, '
        'then shows empty state', (tester) async {
      await tester.pumpWidget(buildWidget(txns: []));
      await tester.pumpAndSettle();

      expect(find.text('還沒有交易紀錄'), findsOneWidget);
    });
  });
}
