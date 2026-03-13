import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:isar/isar.dart';

class IsarAccountRepository implements AccountRepository {
  IsarAccountRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Account>> getAll() async {
    return _isar.accounts.where().findAll();
  }

  @override
  Future<List<Account>> getActive() async {
    return _isar.accounts.filter().isArchivedEqualTo(false).findAll();
  }

  @override
  Future<List<Account>> getByAssetTerm(AssetTerm term) async {
    return _isar.accounts
        .filter()
        .isArchivedEqualTo(false)
        .assetTermEqualTo(term)
        .findAll();
  }

  @override
  Future<Account?> getById(int id) async {
    return _isar.accounts.get(id);
  }

  @override
  Future<int> add(Account account) async {
    return _isar.writeTxn(() => _isar.accounts.put(account));
  }

  @override
  Future<void> update(Account account) async {
    account.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }

  @override
  Future<void> archive(int id) async {
    final account = await _isar.accounts.get(id);
    if (account == null) return;
    account
      ..isArchived = true
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }

  @override
  Future<void> unarchive(int id) async {
    final account = await _isar.accounts.get(id);
    if (account == null) return;
    account
      ..isArchived = false
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.accounts.delete(id));
  }

  @override
  Future<void> updateBalance(int id, double newBalance) async {
    final account = await _isar.accounts.get(id);
    if (account == null) return;
    account
      ..balance = newBalance
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }
}
