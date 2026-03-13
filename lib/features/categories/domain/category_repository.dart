import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';

/// Repository interface for Category CRUD operations.
abstract class CategoryRepository {
  Future<List<Category>> getByType(CategoryType type);
  Future<List<Category>> getParentsByType(CategoryType type);
  Future<List<Category>> getChildrenOf(int parentId);
  Future<Category?> getById(int id);
  Future<int> add(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
  Future<void> deleteWithChildren(int id);
}
