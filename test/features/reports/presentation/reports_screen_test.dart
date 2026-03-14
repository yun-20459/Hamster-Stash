import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/reports/presentation/reports_screen.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository mockTxnRepo;
  late MockCategoryRepository mockCatRepo;

  setUp(() {
    mockTxnRepo = MockTransactionRepository();
    mockCatRepo = MockCategoryRepository();
  });

  Widget buildWidget({List<Transaction>? txns}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);

    when(() => mockTxnRepo.getByDateRange(start, end)).thenAnswer(
      (_) async =>
          txns ??
          [
            Transaction()
              ..id = 1
              ..amount = 500
              ..type = TransactionType.expense
              ..dateTime = now
              ..categoryId = 1
              ..createdAt = now,
            Transaction()
              ..id = 2
              ..amount = 300
              ..type = TransactionType.expense
              ..dateTime = now
              ..categoryId = 2
              ..createdAt = now,
          ],
    );
    when(() => mockCatRepo.getById(1)).thenAnswer(
      (_) async => Category()
        ..id = 1
        ..name = 'Food'
        ..type = CategoryType.expense
        ..iconEmoji = '\u{1F354}'
        ..colorHex = '#FF6B35'
        ..createdAt = now,
    );
    when(() => mockCatRepo.getById(2)).thenAnswer(
      (_) async => Category()
        ..id = 2
        ..name = 'Transport'
        ..type = CategoryType.expense
        ..iconEmoji = '\u{1F697}'
        ..colorHex = '#4ECDC4'
        ..createdAt = now,
    );

    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(mockTxnRepo),
        categoryRepositoryProvider.overrideWithValue(mockCatRepo),
      ],
      child: const MaterialApp(home: ReportsScreen()),
    );
  }

  group('ReportsScreen with real data', () {
    testWidgets('given transactions, '
        'then shows pie chart', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('given transactions, '
        'then shows category names', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('given transactions, '
        'then shows percentages', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('given no transactions, '
        'then shows empty message', (tester) async {
      await tester.pumpWidget(buildWidget(txns: []));
      await tester.pumpAndSettle();

      expect(find.text('本月沒有支出紀錄'), findsOneWidget);
    });

    testWidgets('given reports page, '
        'then shows page title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('報表'), findsOneWidget);
    });
  });
}
