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

  group('TransferService', () {
    test('given same account ids, '
        'when transfer, '
        'then throws ArgumentError', () async {
      expect(
        () => service.transfer(fromAccountId: 1, toAccountId: 1, amount: 500),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('given zero amount, '
        'when transfer, '
        'then throws ArgumentError', () async {
      expect(
        () => service.transfer(fromAccountId: 1, toAccountId: 2, amount: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('given negative amount, '
        'when transfer, '
        'then throws ArgumentError', () async {
      expect(
        () => service.transfer(fromAccountId: 1, toAccountId: 2, amount: -100),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('given from account not found, '
        'when transfer, '
        'then throws StateError', () async {
      when(() => acctRepo.getById(1)).thenAnswer((_) async => null);

      expect(
        () => service.transfer(fromAccountId: 1, toAccountId: 2, amount: 500),
        throwsA(isA<StateError>()),
      );
    });

    test('given to account not found, '
        'when transfer, '
        'then throws StateError', () async {
      when(() => acctRepo.getById(1)).thenAnswer((_) async => _makeAccount());
      when(() => acctRepo.getById(2)).thenAnswer((_) async => null);

      expect(
        () => service.transfer(fromAccountId: 1, toAccountId: 2, amount: 500),
        throwsA(isA<StateError>()),
      );
    });

    test('given same currency accounts, '
        'when transfer, '
        'then deducts from source and adds to target', () async {
      final from = _makeAccount();
      final to = _makeAccount(id: 2, name: 'Bank B', balance: 5000);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 42);

      await service.transfer(fromAccountId: 1, toAccountId: 2, amount: 3000);

      verify(() => acctRepo.updateBalance(1, 7000)).called(1);
      verify(() => acctRepo.updateBalance(2, 8000)).called(1);
      verify(() => txnRepo.add(any())).called(1);
    });

    test('given cross-currency accounts, '
        'when transfer with exchange rate, '
        'then converts amount for target', () async {
      final from = _makeAccount();
      final to = _makeAccount(
        id: 2,
        name: 'USD Account',
        balance: 500,
        currency: 'USD',
      );

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 42);

      // Transfer 3150 TWD → 100 USD (rate 31.5)
      await service.transfer(
        fromAccountId: 1,
        toAccountId: 2,
        amount: 3150,
        exchangeRate: 1 / 31.5,
      );

      verify(() => acctRepo.updateBalance(1, 6850)).called(1);
      verify(() => acctRepo.updateBalance(2, 600)).called(1);
    });

    test('given valid transfer, '
        'when transfer, '
        'then creates transaction with transfer type', () async {
      final from = _makeAccount();
      final to = _makeAccount(id: 2, name: 'Bank B', balance: 5000);

      when(() => acctRepo.getById(1)).thenAnswer((_) async => from);
      when(() => acctRepo.getById(2)).thenAnswer((_) async => to);
      when(() => acctRepo.updateBalance(any(), any())).thenAnswer((_) async {});
      when(() => txnRepo.add(any())).thenAnswer((_) async => 42);

      final id = await service.transfer(
        fromAccountId: 1,
        toAccountId: 2,
        amount: 1000,
        note: 'Monthly savings',
      );

      expect(id, 42);

      final captured =
          verify(() => txnRepo.add(captureAny())).captured.single
              as Transaction;

      expect(captured.type, TransactionType.transfer);
      expect(captured.accountId, 1);
      expect(captured.toAccountId, 2);
      expect(captured.amount, 1000);
      expect(captured.note, 'Monthly savings');
      expect(captured.categoryId, isNull);
    });
  });
}
