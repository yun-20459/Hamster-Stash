import 'package:hamster_stash/core/database/collections/recurring_rule.dart';

/// Repository interface for RecurringRule CRUD operations.
abstract class RecurringRepository {
  Future<List<RecurringRule>> getAll();
  Future<List<RecurringRule>> getActive();
  Future<RecurringRule?> getById(int id);
  Future<int> add(RecurringRule rule);
  Future<void> update(RecurringRule rule);
  Future<void> delete(int id);
}
