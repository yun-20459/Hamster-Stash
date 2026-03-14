import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_repository.dart';

/// Provide the repository — override in tests with a mock.
final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  throw UnimplementedError('recurringRepositoryProvider must be overridden');
});

/// All recurring rules.
final allRecurringRulesProvider = FutureProvider<List<RecurringRule>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.getAll();
});
