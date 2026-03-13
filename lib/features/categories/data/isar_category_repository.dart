import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:isar/isar.dart';

class IsarCategoryRepository implements CategoryRepository {
  IsarCategoryRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Category>> getByType(CategoryType type) async {
    return _isar.categorys
        .filter()
        .typeEqualTo(type)
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<List<Category>> getParentsByType(CategoryType type) async {
    return _isar.categorys
        .filter()
        .typeEqualTo(type)
        .parentIdIsNull()
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<List<Category>> getChildrenOf(int parentId) async {
    return _isar.categorys
        .filter()
        .parentIdEqualTo(parentId)
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<Category?> getById(int id) async {
    return _isar.categorys.get(id);
  }

  @override
  Future<int> add(Category category) async {
    return _isar.writeTxn(() => _isar.categorys.put(category));
  }

  @override
  Future<void> update(Category category) async {
    await _isar.writeTxn(() => _isar.categorys.put(category));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.categorys.delete(id));
  }

  @override
  Future<void> deleteWithChildren(int id) async {
    await _isar.writeTxn(() async {
      // Delete children first
      final children = await _isar.categorys
          .filter()
          .parentIdEqualTo(id)
          .findAll();
      await _isar.categorys.deleteAll(children.map((c) => c.id).toList());
      // Delete parent
      await _isar.categorys.delete(id);
    });
  }
}
