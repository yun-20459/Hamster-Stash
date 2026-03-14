import 'package:hamster_stash/core/database/collections/transaction.dart';

/// Repository interface for Transaction CRUD operations.
abstract class TransactionRepository {
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getByAccountId(int accountId);
  Future<List<Transaction>> getByCategoryId(int categoryId);
  Future<List<Transaction>> getRecent({int limit = 30, int offset = 0});
  Future<Transaction?> getById(int id);
  Future<int> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(int id);
}
