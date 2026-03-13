import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_picker.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

Category _makeCategory({
  int id = 1,
  String name = 'Food',
  CategoryType type = CategoryType.expense,
  String? iconEmoji = '\u{1F354}',
  int? parentId,
  int sortOrder = 0,
}) {
  return Category()
    ..id = id
    ..name = name
    ..type = type
    ..iconEmoji = iconEmoji
    ..colorHex = '#FF6B35'
    ..parentId = parentId
    ..sortOrder = sortOrder
    ..isDefault = false
    ..createdAt = DateTime(2026);
}

void main() {
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();

    // Default stubs
    when(() => mockRepo.getParentsByType(CategoryType.expense)).thenAnswer(
      (_) async => [
        _makeCategory(),
        _makeCategory(id: 2, name: 'Transport', iconEmoji: '\u{1F697}'),
      ],
    );
    when(() => mockRepo.getParentsByType(CategoryType.income)).thenAnswer(
      (_) async => [
        _makeCategory(
          id: 10,
          name: 'Salary',
          type: CategoryType.income,
          iconEmoji: '\u{1F4B0}',
        ),
      ],
    );
    when(() => mockRepo.getChildrenOf(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getChildrenOf(1)).thenAnswer(
      (_) async => [
        _makeCategory(
          id: 100,
          name: 'Groceries',
          parentId: 1,
          iconEmoji: '\u{1F96C}',
        ),
        _makeCategory(
          id: 101,
          name: 'Dining Out',
          parentId: 1,
          iconEmoji: '\u{1F37D}',
        ),
      ],
    );
  });

  Widget buildPicker({
    CategoryType type = CategoryType.expense,
    void Function(Category)? onSelected,
  }) {
    return ProviderScope(
      overrides: [categoryRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: Scaffold(
          body: CategoryPicker(type: type, onSelected: onSelected ?? (_) {}),
        ),
      ),
    );
  }

  group('CategoryPicker', () {
    testWidgets(
      'given expense type, when loaded, '
      'then shows expense parent categories '
      'in grid',
      (tester) async {
        await tester.pumpWidget(buildPicker());
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
      },
    );

    testWidgets(
      'given income type, when loaded, then shows income parent categories',
      (tester) async {
        await tester.pumpWidget(buildPicker(type: CategoryType.income));
        await tester.pumpAndSettle();

        expect(find.text('Salary'), findsOneWidget);
      },
    );

    testWidgets(
      'given parent category with children, '
      'when tapped, '
      'then shows child categories',
      (tester) async {
        await tester.pumpWidget(buildPicker());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Dining Out'), findsOneWidget);
      },
    );

    testWidgets(
      'given child categories shown, when child tapped, then calls onSelected',
      (tester) async {
        Category? selected;
        await tester.pumpWidget(buildPicker(onSelected: (c) => selected = c));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Groceries'));
        await tester.pumpAndSettle();

        expect(selected, isNotNull);
        expect(selected!.name, 'Groceries');
      },
    );

    testWidgets(
      'given parent with no children, '
      'when tapped, '
      'then calls onSelected with parent',
      (tester) async {
        Category? selected;
        await tester.pumpWidget(buildPicker(onSelected: (c) => selected = c));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Transport'));
        await tester.pumpAndSettle();

        expect(selected, isNotNull);
        expect(selected!.name, 'Transport');
      },
    );
  });
}
