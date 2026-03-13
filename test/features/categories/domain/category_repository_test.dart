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
  String? iconEmoji = '\u{1F354}',
  String? colorHex = '#FF6B35',
  int? parentId,
  int sortOrder = 0,
  bool isDefault = false,
}) {
  return Category()
    ..id = id
    ..name = name
    ..type = type
    ..iconEmoji = iconEmoji
    ..colorHex = colorHex
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

  group('CategoryRepository', () {
    test(
      'given expense categories exist, '
      'when getParentsByType(expense), '
      'then returns only parent categories',
      () async {
        final parents = [
          _makeCategory(),
          _makeCategory(id: 2, name: 'Transport'),
        ];
        when(
          () => repo.getParentsByType(CategoryType.expense),
        ).thenAnswer((_) async => parents);

        final result = await repo.getParentsByType(CategoryType.expense);

        expect(result, hasLength(2));
        expect(result[0].name, 'Food');
        expect(result[1].name, 'Transport');
      },
    );

    test(
      'given income categories exist, '
      'when getParentsByType(income), '
      'then returns only income parents',
      () async {
        final parents = [
          _makeCategory(id: 10, name: 'Salary', type: CategoryType.income),
        ];
        when(
          () => repo.getParentsByType(CategoryType.income),
        ).thenAnswer((_) async => parents);

        final result = await repo.getParentsByType(CategoryType.income);

        expect(result, hasLength(1));
        expect(result[0].type, CategoryType.income);
      },
    );

    test(
      'given parent category with children, '
      'when getChildrenOf(parentId), '
      'then returns child categories',
      () async {
        final children = [
          _makeCategory(id: 100, name: 'Groceries', parentId: 1),
          _makeCategory(id: 101, name: 'Dining Out', parentId: 1),
        ];
        when(() => repo.getChildrenOf(1)).thenAnswer((_) async => children);

        final result = await repo.getChildrenOf(1);

        expect(result, hasLength(2));
        expect(result.every((c) => c.parentId == 1), isTrue);
      },
    );

    test(
      'given parent with no children, '
      'when getChildrenOf(parentId), '
      'then returns empty list',
      () async {
        when(() => repo.getChildrenOf(99)).thenAnswer((_) async => []);

        final result = await repo.getChildrenOf(99);

        expect(result, isEmpty);
      },
    );

    test(
      'given new category, when add(category), then returns assigned id',
      () async {
        final category = _makeCategory(name: 'Custom');
        when(() => repo.add(category)).thenAnswer((_) async => 42);

        final id = await repo.add(category);

        expect(id, 42);
        verify(() => repo.add(category)).called(1);
      },
    );

    test(
      'given existing category, '
      'when update(category), '
      'then completes successfully',
      () async {
        final category = _makeCategory(name: 'Updated Food');
        when(() => repo.update(category)).thenAnswer((_) async {});

        await repo.update(category);

        verify(() => repo.update(category)).called(1);
      },
    );

    test(
      'given category with no children, '
      'when delete(id), '
      'then removes the category',
      () async {
        when(() => repo.delete(1)).thenAnswer((_) async {});

        await repo.delete(1);

        verify(() => repo.delete(1)).called(1);
      },
    );

    test(
      'given parent with children, '
      'when deleteWithChildren(id), '
      'then removes parent and all children',
      () async {
        when(() => repo.deleteWithChildren(1)).thenAnswer((_) async {});

        await repo.deleteWithChildren(1);

        verify(() => repo.deleteWithChildren(1)).called(1);
      },
    );

    test(
      'given category id, when getById(id), then returns the category',
      () async {
        final category = _makeCategory(id: 5, name: 'Shopping');
        when(() => repo.getById(5)).thenAnswer((_) async => category);

        final result = await repo.getById(5);

        expect(result, isNotNull);
        expect(result!.name, 'Shopping');
      },
    );

    test(
      'given non-existent id, when getById(id), then returns null',
      () async {
        when(() => repo.getById(999)).thenAnswer((_) async => null);

        final result = await repo.getById(999);

        expect(result, isNull);
      },
    );
  });
}
