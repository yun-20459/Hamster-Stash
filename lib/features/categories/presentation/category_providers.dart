import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';

/// Provide the repository — override in tests with a mock.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError(
    'categoryRepositoryProvider must be overridden with a real implementation',
  );
});

/// Expense parent categories.
final expenseParentsProvider = FutureProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getParentsByType(CategoryType.expense);
});

/// Income parent categories.
final incomeParentsProvider = FutureProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getParentsByType(CategoryType.income);
});

/// Children of a given parent category.
final childrenProvider = FutureProvider.family<List<Category>, int>((
  ref,
  parentId,
) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getChildrenOf(parentId);
});
