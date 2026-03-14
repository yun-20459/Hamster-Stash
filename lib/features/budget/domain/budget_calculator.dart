import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';

enum BudgetStatus { normal, warning, exceeded }

/// Result of budget spending calculation.
class BudgetSpendingResult {
  BudgetSpendingResult({
    required this.spent,
    required this.budget,
    required this.alertThreshold,
  });

  final double spent;
  final double budget;
  final double alertThreshold;

  double get remaining => budget - spent;
  double get ratio => budget > 0 ? spent / budget : 0;
  bool get isOverBudget => spent > budget;

  BudgetStatus get status {
    if (ratio >= 1.0) return BudgetStatus.exceeded;
    if (ratio >= alertThreshold) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }
}

/// Date range for a budget period.
class DateRange {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

/// Calculates how much of a budget has been spent.
///
/// Only counts expense transactions. If the budget's `categoryId` is set,
/// only transactions matching that category are counted.
BudgetSpendingResult calculateBudgetSpending(
  Budget budget,
  List<Transaction> transactions,
) {
  var spent = 0.0;
  for (final txn in transactions) {
    if (txn.type != TransactionType.expense) continue;
    if (budget.categoryId != null && txn.categoryId != budget.categoryId) {
      continue;
    }
    spent += txn.amount;
  }
  return BudgetSpendingResult(
    spent: spent,
    budget: budget.amount,
    alertThreshold: budget.alertThreshold,
  );
}

/// Returns the current period date range for a budget.
DateRange currentPeriodRange(Budget budget, DateTime now) {
  switch (budget.period) {
    case BudgetPeriod.monthly:
      return DateRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1),
      );
    case BudgetPeriod.weekly:
      // weekday: 1=Mon, 7=Sun → Monday-based weeks
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(monday.year, monday.month, monday.day);
      return DateRange(start: start, end: start.add(const Duration(days: 7)));
    case BudgetPeriod.yearly:
      return DateRange(start: DateTime(now.year), end: DateTime(now.year + 1));
  }
}
