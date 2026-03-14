import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:hamster_stash/features/transactions/domain/transfer_service.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class FakeTransaction extends Fake implements Transaction {}

Account _makeAccount({
  int id = 1,
  String name = 'Bank A',
  double balance = 10000,
  String currency = 'TWD',
}) {
  return Account()
    ..id = id
    ..name = name
    ..type = AccountType.bank
    ..balance = balance
    ..currency = currency
    ..createdAt = DateTime(2026);
}

void main() {
  late MockTransactionRepository txnRepo;
  late MockAccountRepository acctRepo;
  late TransferService service;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    txnRepo = MockTransactionRepository();
    acctRepo = MockAccountRepository();
    service = TransferService(
      transactionRepository: txnRepo,
      accountRepository: acctRepo,
    );
  });

  group('TransferService edge cases', () {
    test('given very small amount, '
        'when transfer, '
        'then handles precision', () async {
      final from = _makeAccount(balance: 100);
      final to = _makeAccount(id: 2, name: 'B', balance: 100);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 1);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 0.01);

      verify(() => acctRepo.updateBalance(1, 99.99)).called(1);
      verify(() => acctRepo.updateBalance(2, 100.01)).called(1);
    });

    test('given exchange rate of 1.0 (default), '
        'when transfer, '
        'then no conversion applied', () async {
      final from = _makeAccount(balance: 5000);
      final to = _makeAccount(id: 2, name: 'B', balance: 3000);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 1);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 1000);

      verify(() => acctRepo.updateBalance(1, 4000)).called(1);
      verify(() => acctRepo.updateBalance(2, 4000)).called(1);
    });

    test('given transfer drains source account, '
        'when transfer full balance, '
        'then source becomes zero', () async {
      final from = _makeAccount(balance: 5000);
      final to = _makeAccount(id: 2, name: 'B', balance: 0);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 1);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 5000);

      verify(() => acctRepo.updateBalance(1, 0)).called(1);
      verify(() => acctRepo.updateBalance(2, 5000)).called(1);
    });

    test('given transfer exceeds source balance, '
        'when transfer, '
        'then source goes negative', () async {
      final from = _makeAccount(balance: 1000);
      final to = _makeAccount(id: 2, name: 'B', balance: 0);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 1);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 3000);

      verify(() => acctRepo.updateBalance(1, -2000)).called(1);
    });

    test('given transfer with no note, '
        'when transfer, '
        'then transaction has null note', () async {
      final from = _makeAccount();
      final to = _makeAccount(id: 2, name: 'B', balance: 5000);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 1);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 500);

      final captured =
          verify(() => txnRepo.add(captureAny())).captured.single
              as Transaction;

      expect(captured.note, isNull);
    });
  });
}
