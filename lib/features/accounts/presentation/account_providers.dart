import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';

/// Provide the repository — override in tests with a mock.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  throw UnimplementedError(
    'accountRepositoryProvider must be overridden with a real implementation',
  );
});

/// All active (non-archived) accounts.
final activeAccountsProvider = FutureProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getActive();
});

/// Current (short-term) asset accounts.
final currentAssetsProvider = FutureProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getByAssetTerm(AssetTerm.current);
});

/// Long-term asset accounts.
final longTermAssetsProvider = FutureProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getByAssetTerm(AssetTerm.longTerm);
});

/// Single account by ID.
final accountByIdProvider = FutureProvider.family<Account?, int>((ref, id) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getById(id);
});
