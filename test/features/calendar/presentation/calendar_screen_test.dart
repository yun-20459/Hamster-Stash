import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/calendar/presentation/calendar_screen.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late MockCategoryRepository mockCatRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    mockCatRepo = MockCategoryRepository();
    // Stub any date range query
    when(() => mockRepo.getByDateRange(any(), any())).thenAnswer(
      (_) async => [
        Transaction()
          ..id = 1
          ..amount = 500
          ..type = TransactionType.expense
          ..categoryId = 10
          ..dateTime = DateTime(2026, 3, 13)
          ..createdAt = DateTime(2026),
      ],
    );
    // Stub category lookup: child with parent
    when(() => mockCatRepo.getById(10)).thenAnswer(
      (_) async => Category()
        ..id = 10
        ..name = '午餐'
        ..type = CategoryType.expense
        ..parentId = 1
        ..sortOrder = 4
        ..isDefault = true
        ..createdAt = DateTime(2026),
    );
    when(() => mockCatRepo.getById(1)).thenAnswer(
      (_) async => Category()
        ..id = 1
        ..name = '飲食'
        ..type = CategoryType.expense
        ..sortOrder = 0
        ..isDefault = true
        ..createdAt = DateTime(2026),
    );
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(mockRepo),
        categoryRepositoryProvider.overrideWithValue(mockCatRepo),
      ],
      child: const MaterialApp(home: Scaffold(body: CalendarScreen())),
    );
  }

  group('CalendarScreen with real data', () {
    testWidgets('given calendar displayed, '
        'then shows month header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('2026'), findsWidgets);
    });

    testWidgets('given calendar displayed, '
        'then shows day cells', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('15'), findsWidgets);
    });

    testWidgets('given day selected, '
        'then shows daily transactions section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('當日交易'), findsOneWidget);
    });

    testWidgets('given transaction with category, '
        'then shows parent > child label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tap the day that has the transaction (13th)
      await tester.tap(find.text('13'));
      await tester.pumpAndSettle();

      expect(find.text('飲食 > 午餐'), findsOneWidget);
    });
  });
}
