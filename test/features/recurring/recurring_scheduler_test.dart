import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_scheduler.dart';

RecurringRule _makeRule({
  RecurringFrequency frequency = RecurringFrequency.monthly,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? lastExecutedAt,
  DateTime? nextExecutionAt,
  double amount = 1000,
  TransactionType type = TransactionType.expense,
  int? categoryId,
  int? accountId,
  String? note,
}) {
  final start = startDate ?? DateTime(2026, 1, 1);
  return RecurringRule()
    ..id = 1
    ..amount = amount
    ..transactionType = type
    ..frequency = frequency
    ..categoryId = categoryId
    ..accountId = accountId
    ..note = note
    ..startDate = start
    ..endDate = endDate
    ..lastExecutedAt = lastExecutedAt
    ..nextExecutionAt = nextExecutionAt ?? start
    ..isActive = true
    ..createdAt = DateTime(2026);
}

void main() {
  group('computeDueTransactions', () {
    test('given rule with nextExecution today, '
        'then generates one transaction', () {
      final now = DateTime(2026, 3, 1);
      final rule = _makeRule(
        nextExecutionAt: DateTime(2026, 3, 1),
        amount: 500,
        categoryId: 3,
        accountId: 7,
        note: '房租',
      );

      final result = computeDueTransactions(rule, now);

      expect(result.transactions.length, 1);
      final txn = result.transactions.first;
      expect(txn.amount, 500);
      expect(txn.type, TransactionType.expense);
      expect(txn.categoryId, 3);
      expect(txn.accountId, 7);
      expect(txn.note, '房租');
      expect(txn.isRecurring, isTrue);
      expect(txn.recurringRuleId, 1);
    });

    test('given rule with nextExecution in the past, '
        'then generates multiple catch-up transactions', () {
      final now = DateTime(2026, 4, 15);
      final rule = _makeRule(nextExecutionAt: DateTime(2026, 2, 1));

      final result = computeDueTransactions(rule, now);

      // Feb 1, Mar 1, Apr 1 = 3 transactions
      expect(result.transactions.length, 3);
      expect(result.updatedNextExecution, DateTime(2026, 5, 1));
    });

    test('given rule with nextExecution in the future, '
        'then generates no transactions', () {
      final now = DateTime(2026, 3, 1);
      final rule = _makeRule(nextExecutionAt: DateTime(2026, 4, 1));

      final result = computeDueTransactions(rule, now);

      expect(result.transactions, isEmpty);
      expect(result.updatedNextExecution, DateTime(2026, 4, 1));
    });

    test('given rule with endDate reached, '
        'then stops generating and deactivates', () {
      final now = DateTime(2026, 5, 1);
      final rule = _makeRule(
        nextExecutionAt: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 4, 1),
      );

      final result = computeDueTransactions(rule, now);

      // Mar 1, Apr 1 = 2 (stops at endDate inclusive)
      expect(result.transactions.length, 2);
      expect(result.shouldDeactivate, isTrue);
    });

    test('given inactive rule, '
        'then generates no transactions', () {
      final rule = _makeRule()..isActive = false;
      final now = DateTime(2026, 3, 1);

      final result = computeDueTransactions(rule, now);

      expect(result.transactions, isEmpty);
    });

    test('given daily frequency, '
        'then advances by 1 day', () {
      final now = DateTime(2026, 3, 3);
      final rule = _makeRule(
        frequency: RecurringFrequency.daily,
        nextExecutionAt: DateTime(2026, 3, 1),
      );

      final result = computeDueTransactions(rule, now);

      expect(result.transactions.length, 3);
      expect(result.updatedNextExecution, DateTime(2026, 3, 4));
    });

    test('given weekly frequency, '
        'then advances by 7 days', () {
      final now = DateTime(2026, 3, 22);
      final rule = _makeRule(
        frequency: RecurringFrequency.weekly,
        nextExecutionAt: DateTime(2026, 3, 1),
      );

      final result = computeDueTransactions(rule, now);

      // Mar 1, 8, 15, 22 = 4 transactions
      expect(result.transactions.length, 4);
      expect(result.updatedNextExecution, DateTime(2026, 3, 29));
    });

    test('given yearly frequency, '
        'then advances by 1 year', () {
      final now = DateTime(2028, 1, 1);
      final rule = _makeRule(
        frequency: RecurringFrequency.yearly,
        nextExecutionAt: DateTime(2026, 1, 1),
      );

      final result = computeDueTransactions(rule, now);

      // 2026, 2027, 2028 = 3 transactions
      expect(result.transactions.length, 3);
      expect(result.updatedNextExecution, DateTime(2029, 1, 1));
    });
  });

  group('nextDate', () {
    test('given monthly on Jan 31, then wraps to Feb 28', () {
      final result = nextDate(
        DateTime(2026, 1, 31),
        RecurringFrequency.monthly,
      );
      expect(result, DateTime(2026, 2, 28));
    });

    test('given monthly on Mar 31, then wraps to Apr 30', () {
      final result = nextDate(
        DateTime(2026, 3, 31),
        RecurringFrequency.monthly,
      );
      expect(result, DateTime(2026, 4, 30));
    });

    test('given daily, then adds 1 day', () {
      final result = nextDate(DateTime(2026, 3, 14), RecurringFrequency.daily);
      expect(result, DateTime(2026, 3, 15));
    });

    test('given weekly, then adds 7 days', () {
      final result = nextDate(DateTime(2026, 3, 14), RecurringFrequency.weekly);
      expect(result, DateTime(2026, 3, 21));
    });

    test('given yearly, then adds 1 year', () {
      final result = nextDate(DateTime(2026, 3, 14), RecurringFrequency.yearly);
      expect(result, DateTime(2027, 3, 14));
    });
  });
}
