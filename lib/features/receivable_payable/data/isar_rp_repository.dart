import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_repository.dart';
import 'package:isar/isar.dart';

class IsarRPRepository implements RPRepository {
  IsarRPRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<ReceivablePayable>> getAll() {
    return _isar.receivablePayables.where().findAll();
  }

  @override
  Future<List<ReceivablePayable>> getPending() {
    return _isar.receivablePayables
        .filter()
        .not()
        .statusEqualTo(ReceivablePayableStatus.paid)
        .findAll();
  }

  @override
  Future<ReceivablePayable?> getById(int id) {
    return _isar.receivablePayables.get(id);
  }

  @override
  Future<int> add(ReceivablePayable item) async {
    return _isar.writeTxn(() async {
      return _isar.receivablePayables.put(item);
    });
  }

  @override
  Future<void> update(ReceivablePayable item) async {
    await _isar.writeTxn(() async {
      await _isar.receivablePayables.put(item);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.receivablePayables.delete(id);
    });
  }
}
