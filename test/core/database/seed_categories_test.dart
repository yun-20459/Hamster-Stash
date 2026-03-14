import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/database/seed_categories.dart';

void main() {
  group('Seed category definitions', () {
    test('given expense parents, '
        'when listed, '
        'then contains all 9 categories', () {
      final parents = defaultCategories
          .where((c) => c.parentId == null)
          .toList();
      final expenseParents = parents
          .where((c) => c.type == CategoryType.expense)
          .toList();

      expect(expenseParents.length, 9);
    });

    test('given income parents, '
        'when listed, '
        'then contains all 5 categories', () {
      final parents = defaultCategories
          .where((c) => c.parentId == null)
          .toList();
      final incomeParents = parents
          .where((c) => c.type == CategoryType.income)
          .toList();

      expect(incomeParents.length, 5);
    });

    test('given expense subcategories, '
        'when counted, '
        'then has at least 20', () {
      final subs = defaultCategories.where((c) => c.parentId != null).toList();

      expect(subs.length, greaterThanOrEqualTo(20));
    });

    test('given each parent category, '
        'when checked, '
        'then has emoji and colorHex', () {
      final parents = defaultCategories
          .where((c) => c.parentId == null)
          .toList();

      for (final cat in parents) {
        expect(cat.iconEmoji, isNotNull, reason: '${cat.name} missing emoji');
        expect(cat.colorHex, isNotNull, reason: '${cat.name} missing color');
      }
    });

    test('given food category, '
        'when children listed, '
        'then has expected subcategories', () {
      final food = defaultCategories.firstWhere(
        (c) => c.tempId == 'exp_food' && c.parentId == null,
      );
      final children = defaultCategories
          .where((c) => c.parentId == food.tempId)
          .toList();

      expect(children.length, greaterThanOrEqualTo(5));
    });

    test('given all categories, '
        'when checked, '
        'then all are default', () {
      for (final cat in defaultCategories) {
        expect(cat.isDefault, isTrue, reason: '${cat.name} not default');
      }
    });

    test('given asset term defaults, '
        'when checked, '
        'then maps account types correctly', () {
      expect(defaultAssetTerm(AccountType.cash), AssetTerm.current);
      expect(defaultAssetTerm(AccountType.bank), AssetTerm.current);
      expect(defaultAssetTerm(AccountType.creditCard), AssetTerm.current);
      expect(defaultAssetTerm(AccountType.eWallet), AssetTerm.current);
      expect(defaultAssetTerm(AccountType.investment), AssetTerm.shortTerm);
      expect(defaultAssetTerm(AccountType.other), AssetTerm.current);
    });
  });
}
