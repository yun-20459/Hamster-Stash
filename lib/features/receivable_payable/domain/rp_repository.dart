import 'package:hamster_stash/core/database/collections/receivable_payable.dart';

/// Repository interface for ReceivablePayable CRUD operations.
abstract class RPRepository {
  Future<List<ReceivablePayable>> getAll();
  Future<List<ReceivablePayable>> getPending();
  Future<ReceivablePayable?> getById(int id);
  Future<int> add(ReceivablePayable item);
  Future<void> update(ReceivablePayable item);
  Future<void> delete(int id);
}
