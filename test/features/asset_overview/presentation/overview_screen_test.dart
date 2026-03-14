import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/asset_overview/presentation/overview_screen.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

Account _makeAccount({
  int id = 1,
  String name = 'Bank A',
  double balance = 10000,
  String currency = 'TWD',
  AccountType type = AccountType.bank,
  AssetTerm assetTerm = AssetTerm.current,
}) {
  return Account()
    ..id = id
    ..name = name
    ..type = type
    ..balance = balance
    ..currency = currency
    ..assetTerm = assetTerm
    ..createdAt = DateTime(2026);
}

void main() {
  late MockAccountRepository mockAcctRepo;
  late MockTransactionRepository mockTxnRepo;

  setUp(() {
    mockAcctRepo = MockAccountRepository();
    mockTxnRepo = MockTransactionRepository();
  });

  Widget buildWidget({List<Account>? accounts}) {
    final accts =
        accounts ??
        [
          _makeAccount(balance: 50000),
          _makeAccount(
            id: 2,
            name: 'Investment',
            balance: 100000,
            type: AccountType.investment,
            assetTerm: AssetTerm.longTerm,
          ),
        ];
    when(() => mockAcctRepo.getActive()).thenAnswer((_) async => accts);
    when(() => mockTxnRepo.getRecent()).thenAnswer((_) async => []);

    return ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(mockAcctRepo),
        transactionRepositoryProvider.overrideWithValue(mockTxnRepo),
      ],
      child: const MaterialApp(home: OverviewScreen()),
    );
  }

  group('OverviewScreen with real providers', () {
    testWidgets('given accounts, '
        'then shows total asset card', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('總覽'), findsOneWidget);
      expect(find.text('總資產'), findsOneWidget);
    });

    testWidgets('given accounts, '
        'then shows summary cards', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('短期資產'), findsOneWidget);
      expect(find.text('長期資產'), findsOneWidget);
      expect(find.text('淨資產'), findsOneWidget);
    });

    testWidgets('given accounts, '
        'then shows account names', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bank A'), findsOneWidget);
      expect(find.text('Investment'), findsOneWidget);
    });

    testWidgets('given no accounts, '
        'then shows empty state', (tester) async {
      await tester.pumpWidget(buildWidget(accounts: []));
      await tester.pumpAndSettle();

      expect(find.text('還沒有帳戶'), findsOneWidget);
    });

    testWidgets('given loading state, '
        'then shows progress indicator', (tester) async {
      final completer = Completer<List<Account>>();
      when(() => mockAcctRepo.getActive()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountRepositoryProvider.overrideWithValue(mockAcctRepo),
          ],
          child: const MaterialApp(home: OverviewScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending future
      completer.complete([]);
      await tester.pumpAndSettle();
    });
  });
}
