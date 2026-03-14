import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/features/transactions/domain/transaction_repository.dart';
import 'package:isar/isar.dart';

class IsarTransactionRepository implements TransactionRepository {
  IsarTransactionRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return _isar.transactions
        .filter()
        .dateTimeBetween(start, end)
        .sortByDateTimeDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> getByAccountId(int accountId) async {
    return _isar.transactions
        .filter()
        .accountIdEqualTo(accountId)
        .sortByDateTimeDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> getByCategoryId(int categoryId) async {
    return _isar.transactions
        .filter()
        .categoryIdEqualTo(categoryId)
        .sortByDateTimeDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> getRecent({int limit = 30, int offset = 0}) async {
    return _isar.transactions
        .where()
        .sortByDateTimeDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<Transaction?> getById(int id) async {
    return _isar.transactions.get(id);
  }

  @override
  Future<int> add(Transaction transaction) async {
    return _isar.writeTxn(() => _isar.transactions.put(transaction));
  }

  @override
  Future<void> update(Transaction transaction) async {
    await _isar.writeTxn(() => _isar.transactions.put(transaction));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.transactions.delete(id));
  }
}
