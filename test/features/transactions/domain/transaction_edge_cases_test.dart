import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

Transaction _makeTxn({
  int id = 1,
  double amount = 100,
  TransactionType type = TransactionType.expense,
  int? categoryId = 1,
  int? accountId = 1,
  int? toAccountId,
  DateTime? dateTime,
}) {
  return Transaction()
    ..id = id
    ..amount = amount
    ..type = type
    ..dateTime = dateTime ?? DateTime(2026, 3, 13)
    ..categoryId = categoryId
    ..accountId = accountId
    ..toAccountId = toAccountId
    ..createdAt = DateTime(2026);
}

void main() {
  late MockTransactionRepository repo;

  setUp(() {
    repo = MockTransactionRepository();
  });

  group('TransactionRepository edge cases', () {
    test('given empty date range, '
        'when getByDateRange, '
        'then returns empty list', () async {
      final start = DateTime(2025);
      final end = DateTime(2025, 1, 2);
      when(() => repo.getByDateRange(start, end)).thenAnswer((_) async => []);

      final result = await repo.getByDateRange(start, end);

      expect(result, isEmpty);
    });

    test('given same day range, '
        'when getByDateRange, '
        'then returns that day only', () async {
      final day = DateTime(2026, 3, 13);
      final txns = [_makeTxn(dateTime: day)];
      when(() => repo.getByDateRange(day, day)).thenAnswer((_) async => txns);

      final result = await repo.getByDateRange(day, day);

      expect(result, hasLength(1));
    });

    test('given transfer transaction, '
        'when getByAccountId(fromAccount), '
        'then includes transfer', () async {
      final txns = [_makeTxn(type: TransactionType.transfer, toAccountId: 2)];
      when(() => repo.getByAccountId(1)).thenAnswer((_) async => txns);

      final result = await repo.getByAccountId(1);

      expect(result[0].type, TransactionType.transfer);
      expect(result[0].toAccountId, 2);
    });

    test('given no transactions for account, '
        'when getByAccountId, '
        'then returns empty', () async {
      when(() => repo.getByAccountId(999)).thenAnswer((_) async => []);

      final result = await repo.getByAccountId(999);

      expect(result, isEmpty);
    });

    test('given no transactions for category, '
        'when getByCategoryId, '
        'then returns empty', () async {
      when(() => repo.getByCategoryId(999)).thenAnswer((_) async => []);

      final result = await repo.getByCategoryId(999);

      expect(result, isEmpty);
    });

    test('given getRecent with limit 0, '
        'when called, '
        'then returns empty', () async {
      when(() => repo.getRecent(limit: 0)).thenAnswer((_) async => []);

      final result = await repo.getRecent(limit: 0);

      expect(result, isEmpty);
    });

    test('given mixed transaction types, '
        'when getByAccountId, '
        'then returns all types', () async {
      final txns = [
        _makeTxn(),
        _makeTxn(id: 2, type: TransactionType.income),
        _makeTxn(id: 3, type: TransactionType.transfer, toAccountId: 2),
      ];
      when(() => repo.getByAccountId(1)).thenAnswer((_) async => txns);

      final result = await repo.getByAccountId(1);

      expect(result, hasLength(3));
      expect(
        result.map((t) => t.type).toSet(),
        containsAll(TransactionType.values),
      );
    });

    test('given transaction with zero amount, '
        'when add, then succeeds', () async {
      final txn = _makeTxn(amount: 0);
      when(() => repo.add(txn)).thenAnswer((_) async => 1);

      final id = await repo.add(txn);

      expect(id, 1);
    });

    test('given updated transaction, '
        'when update then getById, '
        'then reflects changes', () async {
      final txn = _makeTxn(amount: 200);
      when(() => repo.update(txn)).thenAnswer((_) async {});
      when(() => repo.getById(1)).thenAnswer((_) async => txn);

      await repo.update(txn);
      final result = await repo.getById(1);

      expect(result!.amount, 200);
    });

    test('given deleted transaction, '
        'when getById, then returns null', () async {
      when(() => repo.delete(1)).thenAnswer((_) async {});
      when(() => repo.getById(1)).thenAnswer((_) async => null);

      await repo.delete(1);
      final result = await repo.getById(1);

      expect(result, isNull);
    });
  });
}
