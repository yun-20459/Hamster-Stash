import 'package:hamster_stash/features/recurring/domain/recurring_repository.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_scheduler.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';

/// Processes all active recurring rules on app startup.
///
/// For each active rule, computes due transactions, saves them,
/// and updates the rule's next execution date.
class RecurringExecutor {
  RecurringExecutor({
    required this.recurringRepo,
    required this.transactionRepo,
  });

  final RecurringRepository recurringRepo;
  final TransactionRepository transactionRepo;

  /// Processes all active rules and returns the total number
  /// of transactions generated.
  Future<int> processAll({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final rules = await recurringRepo.getActive();
    var total = 0;

    for (final rule in rules) {
      final result = computeDueTransactions(rule, currentTime);

      for (final txn in result.transactions) {
        await transactionRepo.add(txn);
      }

      if (result.transactions.isNotEmpty || result.shouldDeactivate) {
        rule
          ..nextExecutionAt = result.updatedNextExecution
          ..lastExecutedAt = currentTime;
        if (result.shouldDeactivate) {
          rule.isActive = false;
        }
        await recurringRepo.update(rule);
      }

      total += result.transactions.length;
    }

    return total;
  }
}
