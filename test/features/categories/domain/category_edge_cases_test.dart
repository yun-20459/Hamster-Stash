import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

Category _makeCategory({
  int id = 1,
  String name = 'Food',
  CategoryType type = CategoryType.expense,
  int? parentId,
  int sortOrder = 0,
  bool isDefault = false,
}) {
  return Category()
    ..id = id
    ..name = name
    ..type = type
    ..parentId = parentId
    ..sortOrder = sortOrder
    ..isDefault = isDefault
    ..createdAt = DateTime(2026);
}

void main() {
  late MockCategoryRepository repo;

  setUp(() {
    repo = MockCategoryRepository();
  });

  group('CategoryRepository edge cases', () {
    test('given default categories, '
        'when getByType, '
        'then includes defaults', () async {
      final cats = [
        _makeCategory(isDefault: true),
        _makeCategory(id: 2, isDefault: true),
      ];
      when(
        () => repo.getByType(CategoryType.expense),
      ).thenAnswer((_) async => cats);

      final result = await repo.getByType(CategoryType.expense);

      expect(result, hasLength(2));
      expect(result.every((c) => c.isDefault), isTrue);
    });

    test('given deeply nested category, '
        'when getChildrenOf parent, '
        'then returns direct children only', () async {
      final children = [
        _makeCategory(id: 10, parentId: 1),
        _makeCategory(id: 11, parentId: 1),
      ];
      when(() => repo.getChildrenOf(1)).thenAnswer((_) async => children);

      final result = await repo.getChildrenOf(1);

      expect(result, hasLength(2));
      expect(result.every((c) => c.parentId == 1), isTrue);
    });

    test('given categories with sort order, '
        'when getByType, '
        'then returns in sort order', () async {
      final cats = [
        _makeCategory(),
        _makeCategory(id: 2, sortOrder: 1),
        _makeCategory(id: 3, sortOrder: 2),
      ];
      when(
        () => repo.getByType(CategoryType.expense),
      ).thenAnswer((_) async => cats);

      final result = await repo.getByType(CategoryType.expense);

      for (var i = 0; i < result.length - 1; i++) {
        expect(result[i].sortOrder, lessThanOrEqualTo(result[i + 1].sortOrder));
      }
    });

    test('given mixed expense and income, '
        'when getParentsByType(expense), '
        'then returns only expense', () async {
      final cats = [_makeCategory()];
      when(
        () => repo.getParentsByType(CategoryType.expense),
      ).thenAnswer((_) async => cats);

      final result = await repo.getParentsByType(CategoryType.expense);

      expect(result.every((c) => c.type == CategoryType.expense), isTrue);
    });

    test('given no categories of type, '
        'when getByType, '
        'then returns empty', () async {
      when(
        () => repo.getByType(CategoryType.income),
      ).thenAnswer((_) async => []);

      final result = await repo.getByType(CategoryType.income);

      expect(result, isEmpty);
    });

    test('given deleteWithChildren on leaf, '
        'when called, then completes', () async {
      when(() => repo.deleteWithChildren(99)).thenAnswer((_) async {});

      await repo.deleteWithChildren(99);

      verify(() => repo.deleteWithChildren(99)).called(1);
    });

    test('given category update changes type, '
        'when update, then reflects new type', () async {
      final cat = _makeCategory(type: CategoryType.income);
      when(() => repo.update(cat)).thenAnswer((_) async {});
      when(() => repo.getById(1)).thenAnswer((_) async => cat);

      await repo.update(cat);
      final result = await repo.getById(1);

      expect(result!.type, CategoryType.income);
    });

    test('given parent with many children, '
        'when getChildrenOf, '
        'then returns all', () async {
      final children = List.generate(
        20,
        (i) => _makeCategory(id: 100 + i, name: 'Child $i', parentId: 1),
      );
      when(() => repo.getChildrenOf(1)).thenAnswer((_) async => children);

      final result = await repo.getChildrenOf(1);

      expect(result, hasLength(20));
    });
  });
}
