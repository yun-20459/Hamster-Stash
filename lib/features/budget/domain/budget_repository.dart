import 'package:hamster_stash/core/database/collections/budget.dart';

/// Manages budget persistence.
abstract class BudgetRepository {
  Future<List<Budget>> getAll();

  Future<List<Budget>> getActive();

  Future<Budget?> getById(int id);

  /// Get budget for a specific category (null = total budget).
  Future<Budget?> getByCategoryId(int? categoryId);

  Future<int> add(Budget budget);

  Future<void> update(Budget budget);

  Future<void> delete(int id);
}
