import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_calculator.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_repository.dart';

/// Provide the repository — override in tests with a mock.
final rpRepositoryProvider = Provider<RPRepository>((ref) {
  throw UnimplementedError('rpRepositoryProvider must be overridden');
});

/// All receivable/payable items.
final allRPItemsProvider = FutureProvider<List<ReceivablePayable>>((ref) {
  final repo = ref.watch(rpRepositoryProvider);
  return repo.getAll();
});

/// Net balance summary.
final rpBalanceSummaryProvider = FutureProvider<RPBalanceSummary>((ref) async {
  final items = await ref.watch(allRPItemsProvider.future);
  return computeNetBalance(items);
});
