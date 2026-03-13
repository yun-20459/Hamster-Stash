import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';

/// Provide the repository — override in tests with a mock.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  throw UnimplementedError('transactionRepositoryProvider must be overridden');
});

/// Recent transactions (default 30).
final recentTransactionsProvider = FutureProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getRecent();
});

/// Single transaction by ID.
final transactionByIdProvider = FutureProvider.family<Transaction?, int>((
  ref,
  id,
) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getById(id);
});
