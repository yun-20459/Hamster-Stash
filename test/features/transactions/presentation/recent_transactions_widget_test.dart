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
  int id = 1,
  double amount = 100,
  TransactionType type = TransactionType.expense,
  String? note,
}) {
  return Transaction()
    ..id = id
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
        home: Scaffold(
          body: SingleChildScrollView(child: RecentTransactionsWidget()),
        ),
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

    testWidgets('given more than 10 transactions, '
        'when displayed, '
        'then shows load more button', (tester) async {
      final manyTxns = List.generate(
        15,
        (i) => _makeTxn(id: i + 1, note: 'Txn $i'),
      );
      await tester.pumpWidget(buildWidget(txns: manyTxns));
      await tester.pumpAndSettle();

      expect(find.text('載入更多'), findsOneWidget);
    });

    testWidgets('given load more tapped, '
        'when displayed, '
        'then shows more transactions', (tester) async {
      final manyTxns = List.generate(
        15,
        (i) => _makeTxn(id: i + 1, note: 'Txn $i'),
      );
      await tester.pumpWidget(buildWidget(txns: manyTxns));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('載入更多'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('載入更多'));
      await tester.pumpAndSettle();

      // All 15 should now be visible, no load more
      expect(find.text('載入更多'), findsNothing);
    });
  });
}
