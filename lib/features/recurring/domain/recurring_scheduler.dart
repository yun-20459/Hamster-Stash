import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';

/// Result of computing due transactions for a recurring rule.
class SchedulerResult {
  SchedulerResult({
    required this.transactions,
    required this.updatedNextExecution,
    this.shouldDeactivate = false,
  });

  final List<Transaction> transactions;
  final DateTime updatedNextExecution;
  final bool shouldDeactivate;
}

/// Computes all transactions that are due for a recurring rule up to [now].
///
/// Returns the generated transactions and the updated next execution date.
/// If the rule's end date is reached, `shouldDeactivate` will be true.
SchedulerResult computeDueTransactions(RecurringRule rule, DateTime now) {
  if (!rule.isActive) {
    return SchedulerResult(
      transactions: [],
      updatedNextExecution: rule.nextExecutionAt ?? rule.startDate,
    );
  }

  final transactions = <Transaction>[];
  var current = rule.nextExecutionAt ?? rule.startDate;
  var deactivate = false;

  while (!current.isAfter(now)) {
    if (rule.endDate != null && current.isAfter(rule.endDate!)) {
      deactivate = true;
      break;
    }

    transactions.add(_createTransaction(rule, current));

    final next = nextDate(current, rule.frequency);

    if (rule.endDate != null && next.isAfter(rule.endDate!)) {
      deactivate = true;
    }

    current = next;
  }

  return SchedulerResult(
    transactions: transactions,
    updatedNextExecution: current,
    shouldDeactivate: deactivate,
  );
}

/// Calculates the next execution date based on frequency.
///
/// For monthly, clamps day to the last day of the target month
/// (e.g. Jan 31 -> Feb 28).
DateTime nextDate(DateTime current, RecurringFrequency frequency) {
  switch (frequency) {
    case RecurringFrequency.daily:
      return DateTime(current.year, current.month, current.day + 1);
    case RecurringFrequency.weekly:
      return DateTime(current.year, current.month, current.day + 7);
    case RecurringFrequency.monthly:
      final targetMonth = current.month + 1;
      final targetYear = current.year + (targetMonth > 12 ? 1 : 0);
      final month = targetMonth > 12 ? targetMonth - 12 : targetMonth;
      // Clamp day to last day of target month
      final lastDay = DateTime(targetYear, month + 1, 0).day;
      final day = current.day > lastDay ? lastDay : current.day;
      return DateTime(targetYear, month, day);
    case RecurringFrequency.yearly:
      return DateTime(current.year + 1, current.month, current.day);
  }
}

Transaction _createTransaction(RecurringRule rule, DateTime date) {
  return Transaction()
    ..amount = rule.amount
    ..type = rule.transactionType
    ..dateTime = date
    ..categoryId = rule.categoryId
    ..accountId = rule.accountId
    ..note = rule.note
    ..isRecurring = true
    ..recurringRuleId = rule.id
    ..createdAt = date;
}
