import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:isar/isar.dart';

/// In-memory representation used to build seed data and
/// referenced by tests. [tempId] is a local key used to
/// link parent ↔ child before Isar assigns real IDs.
class SeedCategory {
  SeedCategory({
    required this.tempId,
    required this.name,
    required this.type,
    required this.iconEmoji,
    required this.colorHex,
    required this.sortOrder,
    this.parentId,
    this.isDefault = true,
  });

  final String tempId;
  final String name;
  final CategoryType type;
  final String iconEmoji;
  final String colorHex;
  final int sortOrder;
  final String? parentId;
  final bool isDefault;
}

// ── Expense parent categories ──────────────────────────

const _expFood = 'exp_food';
const _expTransport = 'exp_transport';
const _expEntertainment = 'exp_entertainment';
const _expShopping = 'exp_shopping';
const _expHousing = 'exp_housing';
const _expMedical = 'exp_medical';
const _expEducation = 'exp_education';
const _expInvestment = 'exp_investment';
const _expOther = 'exp_other';

// ── Income parent categories ───────────────────────────

const _incSalary = 'inc_salary';
const _incBonus = 'inc_bonus';
const _incInvestment = 'inc_investment';
const _incSideJob = 'inc_sidejob';
const _incOther = 'inc_other';

/// All default categories (parents + children).
final List<SeedCategory> defaultCategories = [
  // ── Expense parents ──
  SeedCategory(
    tempId: _expFood,
    name: '飲食',
    type: CategoryType.expense,
    iconEmoji: '\u{1F354}',
    colorHex: '#FF6B35',
    sortOrder: 0,
  ),
  SeedCategory(
    tempId: _expTransport,
    name: '交通',
    type: CategoryType.expense,
    iconEmoji: '\u{1F697}',
    colorHex: '#4ECDC4',
    sortOrder: 1,
  ),
  SeedCategory(
    tempId: _expEntertainment,
    name: '娛樂',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AE}',
    colorHex: '#9B59B6',
    sortOrder: 2,
  ),
  SeedCategory(
    tempId: _expShopping,
    name: '購物',
    type: CategoryType.expense,
    iconEmoji: '\u{1F6D2}',
    colorHex: '#E74C3C',
    sortOrder: 3,
  ),
  SeedCategory(
    tempId: _expHousing,
    name: '居住',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E0}',
    colorHex: '#3498DB',
    sortOrder: 4,
  ),
  SeedCategory(
    tempId: _expMedical,
    name: '醫療',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E5}',
    colorHex: '#E91E63',
    sortOrder: 5,
  ),
  SeedCategory(
    tempId: _expEducation,
    name: '教育',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4DA}',
    colorHex: '#FF9800',
    sortOrder: 6,
  ),
  SeedCategory(
    tempId: _expInvestment,
    name: '投資',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4C8}',
    colorHex: '#2E5090',
    sortOrder: 7,
  ),
  SeedCategory(
    tempId: _expOther,
    name: '其他',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4E6}',
    colorHex: '#95A5A6',
    sortOrder: 8,
  ),

  // ── Income parents ──
  SeedCategory(
    tempId: _incSalary,
    name: '薪資',
    type: CategoryType.income,
    iconEmoji: '\u{1F4B0}',
    colorHex: '#2ECC71',
    sortOrder: 0,
  ),
  SeedCategory(
    tempId: _incBonus,
    name: '獎金',
    type: CategoryType.income,
    iconEmoji: '\u{1F381}',
    colorHex: '#F1C40F',
    sortOrder: 1,
  ),
  SeedCategory(
    tempId: _incInvestment,
    name: '投資收益',
    type: CategoryType.income,
    iconEmoji: '\u{1F4CA}',
    colorHex: '#1ABC9C',
    sortOrder: 2,
  ),
  SeedCategory(
    tempId: _incSideJob,
    name: '兼職',
    type: CategoryType.income,
    iconEmoji: '\u{1F4BC}',
    colorHex: '#3498DB',
    sortOrder: 3,
  ),
  SeedCategory(
    tempId: _incOther,
    name: '其他',
    type: CategoryType.income,
    iconEmoji: '\u{1F4B5}',
    colorHex: '#95A5A6',
    sortOrder: 4,
  ),

  // ── Expense subcategories ──

  // Food children
  SeedCategory(
    tempId: 'sub_groceries',
    name: '食材雜貨',
    type: CategoryType.expense,
    iconEmoji: '\u{1F96C}',
    colorHex: '#FF6B35',
    sortOrder: 0,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_dining',
    name: '外食',
    type: CategoryType.expense,
    iconEmoji: '\u{1F37D}\u{FE0F}',
    colorHex: '#FF6B35',
    sortOrder: 1,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_coffee',
    name: '咖啡飲料',
    type: CategoryType.expense,
    iconEmoji: '\u{2615}',
    colorHex: '#FF6B35',
    sortOrder: 2,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_breakfast',
    name: '早餐',
    type: CategoryType.expense,
    iconEmoji: '\u{1F950}',
    colorHex: '#FF6B35',
    sortOrder: 3,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_lunch',
    name: '午餐',
    type: CategoryType.expense,
    iconEmoji: '\u{1F35C}',
    colorHex: '#FF6B35',
    sortOrder: 4,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_dinner',
    name: '晚餐',
    type: CategoryType.expense,
    iconEmoji: '\u{1F35B}',
    colorHex: '#FF6B35',
    sortOrder: 5,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_snacks',
    name: '零食',
    type: CategoryType.expense,
    iconEmoji: '\u{1F36B}',
    colorHex: '#FF6B35',
    sortOrder: 6,
    parentId: _expFood,
  ),

  // Transport children
  SeedCategory(
    tempId: 'sub_transit',
    name: '大眾運輸',
    type: CategoryType.expense,
    iconEmoji: '\u{1F68C}',
    colorHex: '#4ECDC4',
    sortOrder: 0,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_gas',
    name: '加油',
    type: CategoryType.expense,
    iconEmoji: '\u{26FD}',
    colorHex: '#4ECDC4',
    sortOrder: 1,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_taxi',
    name: '計程車',
    type: CategoryType.expense,
    iconEmoji: '\u{1F695}',
    colorHex: '#4ECDC4',
    sortOrder: 2,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_parking',
    name: '停車',
    type: CategoryType.expense,
    iconEmoji: '\u{1F17F}\u{FE0F}',
    colorHex: '#4ECDC4',
    sortOrder: 3,
    parentId: _expTransport,
  ),

  // Entertainment children
  SeedCategory(
    tempId: 'sub_movies',
    name: '電影',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AC}',
    colorHex: '#9B59B6',
    sortOrder: 0,
    parentId: _expEntertainment,
  ),
  SeedCategory(
    tempId: 'sub_subs',
    name: '訂閱服務',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4FA}',
    colorHex: '#9B59B6',
    sortOrder: 1,
    parentId: _expEntertainment,
  ),
  SeedCategory(
    tempId: 'sub_games',
    name: '遊戲',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AE}',
    colorHex: '#9B59B6',
    sortOrder: 2,
    parentId: _expEntertainment,
  ),

  // Shopping children
  SeedCategory(
    tempId: 'sub_clothing',
    name: '服飾',
    type: CategoryType.expense,
    iconEmoji: '\u{1F455}',
    colorHex: '#E74C3C',
    sortOrder: 0,
    parentId: _expShopping,
  ),
  SeedCategory(
    tempId: 'sub_electronics',
    name: '3C 電子',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4F1}',
    colorHex: '#E74C3C',
    sortOrder: 1,
    parentId: _expShopping,
  ),
  SeedCategory(
    tempId: 'sub_household',
    name: '日用品',
    type: CategoryType.expense,
    iconEmoji: '\u{1F9F4}',
    colorHex: '#E74C3C',
    sortOrder: 2,
    parentId: _expShopping,
  ),

  // Housing children
  SeedCategory(
    tempId: 'sub_rent',
    name: '房租',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E2}',
    colorHex: '#3498DB',
    sortOrder: 0,
    parentId: _expHousing,
  ),
  SeedCategory(
    tempId: 'sub_utilities',
    name: '水電瓦斯',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4A1}',
    colorHex: '#3498DB',
    sortOrder: 1,
    parentId: _expHousing,
  ),
  SeedCategory(
    tempId: 'sub_internet',
    name: '網路電話',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4F6}',
    colorHex: '#3498DB',
    sortOrder: 2,
    parentId: _expHousing,
  ),

  // Medical children
  SeedCategory(
    tempId: 'sub_doctor',
    name: '看診',
    type: CategoryType.expense,
    iconEmoji: '\u{1FA7A}',
    colorHex: '#E91E63',
    sortOrder: 0,
    parentId: _expMedical,
  ),
  SeedCategory(
    tempId: 'sub_pharmacy',
    name: '藥品',
    type: CategoryType.expense,
    iconEmoji: '\u{1F48A}',
    colorHex: '#E91E63',
    sortOrder: 1,
    parentId: _expMedical,
  ),
];

/// Default asset term for each account type.
AssetTerm defaultAssetTerm(AccountType type) {
  switch (type) {
    case AccountType.investment:
      return AssetTerm.shortTerm;
    case AccountType.cash:
    case AccountType.bank:
    case AccountType.creditCard:
    case AccountType.eWallet:
    case AccountType.other:
      return AssetTerm.current;
  }
}

/// Seeds the Isar database with [defaultCategories].
/// Idempotent — inserts if empty, updates default names
/// if categories already exist.
Future<void> seedCategories(Isar isar) async {
  final count = await isar.categorys.count();
  if (count > 0) {
    await _updateDefaultNames(isar);
    return;
  }

  final now = DateTime.now();

  // First pass: insert parents (parentId == null)
  final parents = defaultCategories.where((s) => s.parentId == null).toList();

  final parentCategories = parents.map((s) {
    return Category()
      ..name = s.name
      ..type = s.type
      ..iconEmoji = s.iconEmoji
      ..colorHex = s.colorHex
      ..sortOrder = s.sortOrder
      ..isDefault = s.isDefault
      ..createdAt = now;
  }).toList();

  await isar.writeTxn(() async {
    await isar.categorys.putAll(parentCategories);
  });

  // Build tempId → real Isar ID mapping
  final saved = await isar.categorys.where().findAll();
  final tempIdToRealId = <String, int>{};
  for (var i = 0; i < parents.length; i++) {
    // Match by name + type to be safe
    final match = saved.firstWhere(
      (c) => c.name == parents[i].name && c.type == parents[i].type,
    );
    tempIdToRealId[parents[i].tempId] = match.id;
  }

  // Second pass: insert children
  final children = defaultCategories.where((s) => s.parentId != null).toList();

  final childCategories = children.map((s) {
    return Category()
      ..name = s.name
      ..type = s.type
      ..iconEmoji = s.iconEmoji
      ..colorHex = s.colorHex
      ..parentId = tempIdToRealId[s.parentId!]
      ..sortOrder = s.sortOrder
      ..isDefault = s.isDefault
      ..createdAt = now;
  }).toList();

  await isar.writeTxn(() async {
    await isar.categorys.putAll(childCategories);
  });
}

/// Updates names, emojis, and colors of existing default
/// categories to match the current seed data.
Future<void> _updateDefaultNames(Isar isar) async {
  final existing = await isar.categorys
      .filter()
      .isDefaultEqualTo(true)
      .findAll();
  if (existing.isEmpty) return;

  // Build a lookup from (type, sortOrder, isParent) to
  // the seed data so we can match without relying on name.
  final seeds = defaultCategories;
  final parents = seeds.where((s) => s.parentId == null);

  var updated = false;
  await isar.writeTxn(() async {
    for (final seed in parents) {
      final match = existing
          .where(
            (c) =>
                c.type == seed.type &&
                c.sortOrder == seed.sortOrder &&
                c.parentId == null,
          )
          .toList();
      if (match.isEmpty) continue;
      final cat = match.first;
      if (cat.name != seed.name || cat.iconEmoji != seed.iconEmoji) {
        cat
          ..name = seed.name
          ..iconEmoji = seed.iconEmoji
          ..colorHex = seed.colorHex;
        await isar.categorys.put(cat);
        updated = true;
      }
    }

    // Update children too
    for (final seed in seeds.where((s) => s.parentId != null)) {
      // Find the parent's real ID
      final parentSeed = parents.firstWhere((p) => p.tempId == seed.parentId);
      final parentMatch = existing
          .where(
            (c) =>
                c.type == parentSeed.type &&
                c.sortOrder == parentSeed.sortOrder &&
                c.parentId == null,
          )
          .toList();
      if (parentMatch.isEmpty) continue;
      final parentId = parentMatch.first.id;

      final childMatch = existing
          .where((c) => c.parentId == parentId && c.sortOrder == seed.sortOrder)
          .toList();
      if (childMatch.isEmpty) continue;
      final cat = childMatch.first;
      if (cat.name != seed.name || cat.iconEmoji != seed.iconEmoji) {
        cat
          ..name = seed.name
          ..iconEmoji = seed.iconEmoji
          ..colorHex = seed.colorHex;
        await isar.categorys.put(cat);
        updated = true;
      }
    }
  });

  if (updated) {
    // ignore: avoid_print
    print(
      'Updated default category names to '
      'Traditional Chinese',
    );
  }
}
