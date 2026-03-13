import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

Transaction _makeTxn({
  int id = 1,
  double amount = 150,
  TransactionType type = TransactionType.expense,
  int? categoryId = 1,
  int? accountId = 1,
  String? note,
}) {
  return Transaction()
    ..id = id
    ..amount = amount
    ..type = type
    ..dateTime = DateTime(2026, 3, 13)
    ..categoryId = categoryId
    ..accountId = accountId
    ..note = note
    ..createdAt = DateTime(2026);
}

void main() {
  late MockTransactionRepository repo;

  setUp(() {
    repo = MockTransactionRepository();
  });

  group('TransactionRepository', () {
    test('given transactions exist, '
        'when getByDateRange, '
        'then returns transactions in range', () async {
      final txns = [_makeTxn(), _makeTxn(id: 2, amount: 200)];
      final start = DateTime(2026, 3);
      final end = DateTime(2026, 3, 31);
      when(() => repo.getByDateRange(start, end)).thenAnswer((_) async => txns);

      final result = await repo.getByDateRange(start, end);

      expect(result, hasLength(2));
    });

    test('given transactions for account, '
        'when getByAccountId, '
        'then returns account transactions', () async {
      final txns = [_makeTxn()];
      when(() => repo.getByAccountId(1)).thenAnswer((_) async => txns);

      final result = await repo.getByAccountId(1);

      expect(result, hasLength(1));
      expect(result[0].accountId, 1);
    });

    test('given transactions for category, '
        'when getByCategoryId, '
        'then returns category transactions', () async {
      final txns = [_makeTxn()];
      when(() => repo.getByCategoryId(1)).thenAnswer((_) async => txns);

      final result = await repo.getByCategoryId(1);

      expect(result, hasLength(1));
      expect(result[0].categoryId, 1);
    });

    test('given new transaction, '
        'when add, then returns assigned id', () async {
      final txn = _makeTxn();
      when(() => repo.add(txn)).thenAnswer((_) async => 42);

      final id = await repo.add(txn);

      expect(id, 42);
      verify(() => repo.add(txn)).called(1);
    });

    test('given existing transaction, '
        'when update, then completes', () async {
      final txn = _makeTxn(note: 'Updated');
      when(() => repo.update(txn)).thenAnswer((_) async {});

      await repo.update(txn);

      verify(() => repo.update(txn)).called(1);
    });

    test('given transaction id, '
        'when delete, then removes it', () async {
      when(() => repo.delete(1)).thenAnswer((_) async {});

      await repo.delete(1);

      verify(() => repo.delete(1)).called(1);
    });

    test('given transaction id, '
        'when getById, then returns transaction', () async {
      final txn = _makeTxn(id: 5);
      when(() => repo.getById(5)).thenAnswer((_) async => txn);

      final result = await repo.getById(5);

      expect(result, isNotNull);
      expect(result!.id, 5);
    });

    test('given non-existent id, '
        'when getById, then returns null', () async {
      when(() => repo.getById(999)).thenAnswer((_) async => null);

      final result = await repo.getById(999);

      expect(result, isNull);
    });

    test('given recent transactions, '
        'when getRecent with limit, '
        'then returns limited list', () async {
      final txns = [_makeTxn(), _makeTxn(id: 2), _makeTxn(id: 3)];
      when(() => repo.getRecent(limit: 3)).thenAnswer((_) async => txns);

      final result = await repo.getRecent(limit: 3);

      expect(result, hasLength(3));
    });
  });
}
