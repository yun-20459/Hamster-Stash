import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/bookkeeping_screen.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockAccountRepository mockAcctRepo;
  late MockCategoryRepository mockCatRepo;
  late MockTransactionRepository mockTxnRepo;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockAcctRepo = MockAccountRepository();
    mockCatRepo = MockCategoryRepository();
    mockTxnRepo = MockTransactionRepository();

    when(() => mockAcctRepo.getActive()).thenAnswer(
      (_) async => [
        Account()
          ..id = 1
          ..name = 'Bank'
          ..type = AccountType.bank
          ..balance = 10000
          ..currency = 'TWD'
          ..createdAt = DateTime(2026),
      ],
    );
    when(
      () => mockCatRepo.getParentsByType(CategoryType.expense),
    ).thenAnswer((_) async => []);
    when(
      () => mockCatRepo.getParentsByType(CategoryType.income),
    ).thenAnswer((_) async => []);
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(mockAcctRepo),
        categoryRepositoryProvider.overrideWithValue(mockCatRepo),
        transactionRepositoryProvider.overrideWithValue(mockTxnRepo),
      ],
      child: const MaterialApp(home: BookkeepingScreen()),
    );
  }

  group('BookkeepingScreen', () {
    testWidgets('given bookkeeping page, '
        'then shows FAB with add icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('given FAB tapped, '
        'then shows transaction form', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('新增記帳'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget);
      expect(find.text('收入'), findsOneWidget);
      expect(find.text('轉帳'), findsOneWidget);
    });

    testWidgets('given form with amount, '
        'when save tapped, '
        'then calls repository add', (tester) async {
      when(() => mockTxnRepo.add(any())).thenAnswer((_) async => 1);
      when(() => mockAcctRepo.getById(any())).thenAnswer(
        (_) async => Account()
          ..id = 1
          ..name = 'Bank'
          ..type = AccountType.bank
          ..balance = 10000
          ..currency = 'TWD'
          ..createdAt = DateTime(2026),
      );
      when(
        () => mockAcctRepo.updateBalance(any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(find.byType(TextField).first, '500');
      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      verify(() => mockTxnRepo.add(any())).called(1);
    });

    testWidgets('given form saved, '
        'then shows snackbar confirmation', (tester) async {
      when(() => mockTxnRepo.add(any())).thenAnswer((_) async => 1);
      when(() => mockAcctRepo.getById(any())).thenAnswer(
        (_) async => Account()
          ..id = 1
          ..name = 'Bank'
          ..type = AccountType.bank
          ..balance = 10000
          ..currency = 'TWD'
          ..createdAt = DateTime(2026),
      );
      when(
        () => mockAcctRepo.updateBalance(any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '500');
      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      expect(find.text('記帳成功'), findsOneWidget);
    });
  });
}
