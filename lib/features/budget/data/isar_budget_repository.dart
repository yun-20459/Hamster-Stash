import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/features/budget/domain/budget_repository.dart';
import 'package:isar/isar.dart';

class IsarBudgetRepository implements BudgetRepository {
  IsarBudgetRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Budget>> getAll() {
    return _isar.budgets.where().findAll();
  }

  @override
  Future<List<Budget>> getActive() {
    return _isar.budgets.filter().isActiveEqualTo(true).findAll();
  }

  @override
  Future<Budget?> getById(int id) {
    return _isar.budgets.get(id);
  }

  @override
  Future<Budget?> getByCategoryId(int? categoryId) {
    if (categoryId == null) {
      return _isar.budgets
          .filter()
          .categoryIdIsNull()
          .isActiveEqualTo(true)
          .findFirst();
    }
    return _isar.budgets
        .filter()
        .categoryIdEqualTo(categoryId)
        .isActiveEqualTo(true)
        .findFirst();
  }

  @override
  Future<int> add(Budget budget) async {
    return _isar.writeTxn(() async {
      return _isar.budgets.put(budget);
    });
  }

  @override
  Future<void> update(Budget budget) async {
    await _isar.writeTxn(() async {
      await _isar.budgets.put(budget);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.budgets.delete(id);
    });
  }
}
