import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/features/budget/domain/budget_calculator.dart';
import 'package:hamster_stash/features/budget/domain/budget_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

/// Provide the repository — override in tests with a mock.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  throw UnimplementedError('budgetRepositoryProvider must be overridden');
});

/// All active budgets.
final activeBudgetsProvider = FutureProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getActive();
});

/// Budget spending result for a given budget, calculated
/// from transactions in the current period.
final budgetSpendingProvider =
    FutureProvider.family<BudgetSpendingResult, Budget>((ref, budget) async {
      final txnRepo = ref.watch(transactionRepositoryProvider);
      final range = currentPeriodRange(budget, DateTime.now());
      final txns = await txnRepo.getByDateRange(range.start, range.end);
      return calculateBudgetSpending(budget, txns);
    });
