import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/budget/domain/budget_calculator.dart';

Transaction _makeTxn({
  double amount = 100,
  TransactionType type = TransactionType.expense,
  int? categoryId,
}) {
  return Transaction()
    ..id = 1
    ..amount = amount
    ..type = type
    ..categoryId = categoryId
    ..dateTime = DateTime(2026, 3, 10)
    ..createdAt = DateTime(2026);
}

Budget _makeBudget({
  double amount = 1000,
  int? categoryId,
  double alertThreshold = 0.8,
  bool carryOver = false,
}) {
  return Budget()
    ..id = 1
    ..name = 'Test'
    ..amount = amount
    ..period = BudgetPeriod.monthly
    ..categoryId = categoryId
    ..startDate = DateTime(2026, 3)
    ..alertThreshold = alertThreshold
    ..carryOver = carryOver
    ..createdAt = DateTime(2026);
}

void main() {
  group('calculateBudgetSpending', () {
    test('given total budget with expenses, '
        'then sums all expense amounts', () {
      final budget = _makeBudget();
      final txns = [
        _makeTxn(amount: 200),
        _makeTxn(amount: 300),
        _makeTxn(amount: 150),
      ];

      final result = calculateBudgetSpending(budget, txns);

      expect(result.spent, 650);
      expect(result.remaining, 350);
      expect(result.ratio, closeTo(0.65, 0.001));
    });

    test('given category budget, '
        'then only sums matching category expenses', () {
      final budget = _makeBudget(categoryId: 5);
      final txns = [
        _makeTxn(amount: 200, categoryId: 5),
        _makeTxn(amount: 300, categoryId: 5),
        _makeTxn(amount: 999, categoryId: 99),
      ];

      final result = calculateBudgetSpending(budget, txns);

      expect(result.spent, 500);
      expect(result.remaining, 500);
    });

    test('given income transactions, '
        'then ignores them', () {
      final budget = _makeBudget();
      final txns = [
        _makeTxn(amount: 200),
        _makeTxn(amount: 5000, type: TransactionType.income),
      ];

      final result = calculateBudgetSpending(budget, txns);

      expect(result.spent, 200);
    });

    test('given transfer transactions, '
        'then ignores them', () {
      final budget = _makeBudget();
      final txns = [
        _makeTxn(amount: 200),
        _makeTxn(amount: 1000, type: TransactionType.transfer),
      ];

      final result = calculateBudgetSpending(budget, txns);

      expect(result.spent, 200);
    });

    test('given overspent budget, '
        'then remaining is negative', () {
      final budget = _makeBudget(amount: 500);
      final txns = [_makeTxn(amount: 300), _makeTxn(amount: 400)];

      final result = calculateBudgetSpending(budget, txns);

      expect(result.spent, 700);
      expect(result.remaining, -200);
      expect(result.ratio, closeTo(1.4, 0.001));
      expect(result.isOverBudget, isTrue);
    });

    test('given no transactions, '
        'then spent is 0', () {
      final budget = _makeBudget();
      final result = calculateBudgetSpending(budget, []);

      expect(result.spent, 0);
      expect(result.remaining, 1000);
      expect(result.ratio, 0);
    });
  });

  group('BudgetStatus', () {
    test('given ratio below threshold, '
        'then status is normal', () {
      final result = BudgetSpendingResult(
        spent: 500,
        budget: 1000,
        alertThreshold: 0.8,
      );
      expect(result.status, BudgetStatus.normal);
    });

    test('given ratio at threshold, '
        'then status is warning', () {
      final result = BudgetSpendingResult(
        spent: 800,
        budget: 1000,
        alertThreshold: 0.8,
      );
      expect(result.status, BudgetStatus.warning);
    });

    test('given ratio above 1.0, '
        'then status is exceeded', () {
      final result = BudgetSpendingResult(
        spent: 1100,
        budget: 1000,
        alertThreshold: 0.8,
      );
      expect(result.status, BudgetStatus.exceeded);
    });
  });

  group('currentPeriodRange', () {
    test('given monthly budget, '
        'then returns current month range', () {
      final budget = _makeBudget()..period = BudgetPeriod.monthly;
      final now = DateTime(2026, 3, 14);

      final range = currentPeriodRange(budget, now);

      expect(range.start, DateTime(2026, 3));
      expect(range.end, DateTime(2026, 4));
    });

    test('given weekly budget, '
        'then returns current week range', () {
      final budget = _makeBudget()..period = BudgetPeriod.weekly;
      // 2026-03-14 is Saturday
      final now = DateTime(2026, 3, 14);

      final range = currentPeriodRange(budget, now);

      // Monday of that week is March 9
      expect(range.start, DateTime(2026, 3, 9));
      // End = start + 7 days
      expect(range.end, DateTime(2026, 3, 16));
    });

    test('given yearly budget, '
        'then returns current year range', () {
      final budget = _makeBudget()..period = BudgetPeriod.yearly;
      final now = DateTime(2026, 3, 14);

      final range = currentPeriodRange(budget, now);

      expect(range.start, DateTime(2026));
      expect(range.end, DateTime(2027));
    });
  });
}
