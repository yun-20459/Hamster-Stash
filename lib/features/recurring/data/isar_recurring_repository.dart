import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/features/recurring/domain/recurring_repository.dart';
import 'package:isar/isar.dart';

class IsarRecurringRepository implements RecurringRepository {
  IsarRecurringRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<RecurringRule>> getAll() {
    return _isar.recurringRules.where().findAll();
  }

  @override
  Future<List<RecurringRule>> getActive() {
    return _isar.recurringRules.filter().isActiveEqualTo(true).findAll();
  }

  @override
  Future<RecurringRule?> getById(int id) {
    return _isar.recurringRules.get(id);
  }

  @override
  Future<int> add(RecurringRule rule) async {
    return _isar.writeTxn(() async {
      return _isar.recurringRules.put(rule);
    });
  }

  @override
  Future<void> update(RecurringRule rule) async {
    await _isar.writeTxn(() async {
      await _isar.recurringRules.put(rule);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.recurringRules.delete(id);
    });
  }
}
