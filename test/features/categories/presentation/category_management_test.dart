import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/domain/category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_management.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class FakeCategory extends Fake implements Category {}

Category _makeCat({
  int id = 1,
  String name = 'Food',
  CategoryType type = CategoryType.expense,
  String emoji = '\u{1F354}',
  int? parentId,
  bool isDefault = true,
}) {
  return Category()
    ..id = id
    ..name = name
    ..type = type
    ..iconEmoji = emoji
    ..colorHex = '#FF6B35'
    ..parentId = parentId
    ..sortOrder = 0
    ..isDefault = isDefault
    ..createdAt = DateTime(2026);
}

void main() {
  late MockCategoryRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeCategory());
  });

  setUp(() {
    mockRepo = MockCategoryRepository();
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [categoryRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: Scaffold(body: CategoryManagement())),
    );
  }

  group('CategoryManagement', () {
    testWidgets('given expense categories, '
        'then shows category list', (tester) async {
      when(() => mockRepo.getParentsByType(CategoryType.expense)).thenAnswer(
        (_) async => [_makeCat(), _makeCat(id: 2, name: 'Transport')],
      );
      when(
        () => mockRepo.getParentsByType(CategoryType.income),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('given expense/income tabs, '
        'then can switch between them', (tester) async {
      when(
        () => mockRepo.getParentsByType(CategoryType.expense),
      ).thenAnswer((_) async => [_makeCat()]);
      when(
        () => mockRepo.getParentsByType(CategoryType.income),
      ).thenAnswer((_) async => [_makeCat(id: 3, name: 'Salary')]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);

      await tester.tap(find.text('收入'));
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('given add button, '
        'when tapped, '
        'then shows add dialog', (tester) async {
      when(
        () => mockRepo.getParentsByType(CategoryType.expense),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepo.getParentsByType(CategoryType.income),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('新增分類'), findsOneWidget);
    });

    testWidgets('given non-default category tapped, '
        'when edit chosen, '
        'then shows edit dialog with name and emoji fields', (tester) async {
      final editCat = _makeCat(id: 10, name: 'Custom', isDefault: false);
      when(
        () => mockRepo.getParentsByType(CategoryType.expense),
      ).thenAnswer((_) async => [editCat]);
      when(
        () => mockRepo.getParentsByType(CategoryType.income),
      ).thenAnswer((_) async => []);
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tap the category tile to open edit
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(find.text('編輯分類'), findsOneWidget);
      expect(find.text('分類名稱'), findsOneWidget);
      expect(find.text('圖示 Emoji'), findsOneWidget);
    });
  });
}
