import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

Category _makeCategory({
  int id = 1,
  String name = 'Food',
  CategoryType type = CategoryType.expense,
  int? parentId,
  int sortOrder = 0,
}) {
  return Category()
    ..id = id
    ..name = name
    ..type = type
    ..iconEmoji = '\u{1F354}'
    ..colorHex = '#FF6B35'
    ..parentId = parentId
    ..sortOrder = sortOrder
    ..isDefault = false
    ..createdAt = DateTime(2026);
}

void main() {
  late MockCategoryRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockCategoryRepository();
    container = ProviderContainer(
      overrides: [categoryRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('expenseParentsProvider', () {
    test(
      'given expense parents exist, when reading provider, then returns expense parent list',
      () async {
        final parents = [
          _makeCategory(id: 1, name: 'Food'),
          _makeCategory(id: 2, name: 'Transport'),
        ];
        when(
          () => mockRepo.getParentsByType(CategoryType.expense),
        ).thenAnswer((_) async => parents);

        final result = await container.read(expenseParentsProvider.future);

        expect(result, hasLength(2));
        expect(result[0].name, 'Food');
      },
    );
  });

  group('incomeParentsProvider', () {
    test(
      'given income parents exist, when reading provider, then returns income parent list',
      () async {
        final parents = [
          _makeCategory(id: 10, name: 'Salary', type: CategoryType.income),
        ];
        when(
          () => mockRepo.getParentsByType(CategoryType.income),
        ).thenAnswer((_) async => parents);

        final result = await container.read(incomeParentsProvider.future);

        expect(result, hasLength(1));
        expect(result[0].name, 'Salary');
      },
    );
  });

  group('childrenProvider', () {
    test(
      'given parent has children, when reading childrenProvider(parentId), then returns children',
      () async {
        final children = [
          _makeCategory(id: 100, name: 'Groceries', parentId: 1),
          _makeCategory(id: 101, name: 'Dining Out', parentId: 1),
        ];
        when(() => mockRepo.getChildrenOf(1)).thenAnswer((_) async => children);

        final result = await container.read(childrenProvider(1).future);

        expect(result, hasLength(2));
      },
    );
  });
}
