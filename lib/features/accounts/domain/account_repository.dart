import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';

/// Repository interface for Account CRUD operations.
abstract class AccountRepository {
  Future<List<Account>> getAll();
  Future<List<Account>> getActive();
  Future<List<Account>> getByAssetTerm(AssetTerm term);
  Future<Account?> getById(int id);
  Future<int> add(Account account);
  Future<void> update(Account account);
  Future<void> archive(int id);
  Future<void> unarchive(int id);
  Future<void> delete(int id);
  Future<void> updateBalance(int id, double newBalance);
}
