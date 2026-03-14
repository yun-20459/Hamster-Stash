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
    name: 'Food',
    type: CategoryType.expense,
    iconEmoji: '\u{1F354}',
    colorHex: '#FF6B35',
    sortOrder: 0,
  ),
  SeedCategory(
    tempId: _expTransport,
    name: 'Transport',
    type: CategoryType.expense,
    iconEmoji: '\u{1F697}',
    colorHex: '#4ECDC4',
    sortOrder: 1,
  ),
  SeedCategory(
    tempId: _expEntertainment,
    name: 'Entertainment',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AE}',
    colorHex: '#9B59B6',
    sortOrder: 2,
  ),
  SeedCategory(
    tempId: _expShopping,
    name: 'Shopping',
    type: CategoryType.expense,
    iconEmoji: '\u{1F6D2}',
    colorHex: '#E74C3C',
    sortOrder: 3,
  ),
  SeedCategory(
    tempId: _expHousing,
    name: 'Housing',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E0}',
    colorHex: '#3498DB',
    sortOrder: 4,
  ),
  SeedCategory(
    tempId: _expMedical,
    name: 'Medical',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E5}',
    colorHex: '#E91E63',
    sortOrder: 5,
  ),
  SeedCategory(
    tempId: _expEducation,
    name: 'Education',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4DA}',
    colorHex: '#FF9800',
    sortOrder: 6,
  ),
  SeedCategory(
    tempId: _expInvestment,
    name: 'Investment',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4C8}',
    colorHex: '#2E5090',
    sortOrder: 7,
  ),
  SeedCategory(
    tempId: _expOther,
    name: 'Other',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4E6}',
    colorHex: '#95A5A6',
    sortOrder: 8,
  ),

  // ── Income parents ──
  SeedCategory(
    tempId: _incSalary,
    name: 'Salary',
    type: CategoryType.income,
    iconEmoji: '\u{1F4B0}',
    colorHex: '#2ECC71',
    sortOrder: 0,
  ),
  SeedCategory(
    tempId: _incBonus,
    name: 'Bonus',
    type: CategoryType.income,
    iconEmoji: '\u{1F381}',
    colorHex: '#F1C40F',
    sortOrder: 1,
  ),
  SeedCategory(
    tempId: _incInvestment,
    name: 'Investment Returns',
    type: CategoryType.income,
    iconEmoji: '\u{1F4CA}',
    colorHex: '#1ABC9C',
    sortOrder: 2,
  ),
  SeedCategory(
    tempId: _incSideJob,
    name: 'Side Job',
    type: CategoryType.income,
    iconEmoji: '\u{1F4BC}',
    colorHex: '#3498DB',
    sortOrder: 3,
  ),
  SeedCategory(
    tempId: _incOther,
    name: 'Other',
    type: CategoryType.income,
    iconEmoji: '\u{1F4B5}',
    colorHex: '#95A5A6',
    sortOrder: 4,
  ),

  // ── Expense subcategories ──

  // Food children
  SeedCategory(
    tempId: 'sub_groceries',
    name: 'Groceries',
    type: CategoryType.expense,
    iconEmoji: '\u{1F96C}',
    colorHex: '#FF6B35',
    sortOrder: 0,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_dining',
    name: 'Dining Out',
    type: CategoryType.expense,
    iconEmoji: '\u{1F37D}\u{FE0F}',
    colorHex: '#FF6B35',
    sortOrder: 1,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_coffee',
    name: 'Coffee & Drinks',
    type: CategoryType.expense,
    iconEmoji: '\u{2615}',
    colorHex: '#FF6B35',
    sortOrder: 2,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_breakfast',
    name: 'Breakfast',
    type: CategoryType.expense,
    iconEmoji: '\u{1F950}',
    colorHex: '#FF6B35',
    sortOrder: 3,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_lunch',
    name: 'Lunch',
    type: CategoryType.expense,
    iconEmoji: '\u{1F35C}',
    colorHex: '#FF6B35',
    sortOrder: 4,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_dinner',
    name: 'Dinner',
    type: CategoryType.expense,
    iconEmoji: '\u{1F35B}',
    colorHex: '#FF6B35',
    sortOrder: 5,
    parentId: _expFood,
  ),
  SeedCategory(
    tempId: 'sub_snacks',
    name: 'Snacks',
    type: CategoryType.expense,
    iconEmoji: '\u{1F36B}',
    colorHex: '#FF6B35',
    sortOrder: 6,
    parentId: _expFood,
  ),

  // Transport children
  SeedCategory(
    tempId: 'sub_transit',
    name: 'Public Transit',
    type: CategoryType.expense,
    iconEmoji: '\u{1F68C}',
    colorHex: '#4ECDC4',
    sortOrder: 0,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_gas',
    name: 'Gas',
    type: CategoryType.expense,
    iconEmoji: '\u{26FD}',
    colorHex: '#4ECDC4',
    sortOrder: 1,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_taxi',
    name: 'Taxi & Ride Share',
    type: CategoryType.expense,
    iconEmoji: '\u{1F695}',
    colorHex: '#4ECDC4',
    sortOrder: 2,
    parentId: _expTransport,
  ),
  SeedCategory(
    tempId: 'sub_parking',
    name: 'Parking',
    type: CategoryType.expense,
    iconEmoji: '\u{1F17F}\u{FE0F}',
    colorHex: '#4ECDC4',
    sortOrder: 3,
    parentId: _expTransport,
  ),

  // Entertainment children
  SeedCategory(
    tempId: 'sub_movies',
    name: 'Movies',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AC}',
    colorHex: '#9B59B6',
    sortOrder: 0,
    parentId: _expEntertainment,
  ),
  SeedCategory(
    tempId: 'sub_subs',
    name: 'Subscriptions',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4FA}',
    colorHex: '#9B59B6',
    sortOrder: 1,
    parentId: _expEntertainment,
  ),
  SeedCategory(
    tempId: 'sub_games',
    name: 'Games',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3AE}',
    colorHex: '#9B59B6',
    sortOrder: 2,
    parentId: _expEntertainment,
  ),

  // Shopping children
  SeedCategory(
    tempId: 'sub_clothing',
    name: 'Clothing',
    type: CategoryType.expense,
    iconEmoji: '\u{1F455}',
    colorHex: '#E74C3C',
    sortOrder: 0,
    parentId: _expShopping,
  ),
  SeedCategory(
    tempId: 'sub_electronics',
    name: 'Electronics',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4F1}',
    colorHex: '#E74C3C',
    sortOrder: 1,
    parentId: _expShopping,
  ),
  SeedCategory(
    tempId: 'sub_household',
    name: 'Household',
    type: CategoryType.expense,
    iconEmoji: '\u{1F9F4}',
    colorHex: '#E74C3C',
    sortOrder: 2,
    parentId: _expShopping,
  ),

  // Housing children
  SeedCategory(
    tempId: 'sub_rent',
    name: 'Rent',
    type: CategoryType.expense,
    iconEmoji: '\u{1F3E2}',
    colorHex: '#3498DB',
    sortOrder: 0,
    parentId: _expHousing,
  ),
  SeedCategory(
    tempId: 'sub_utilities',
    name: 'Utilities',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4A1}',
    colorHex: '#3498DB',
    sortOrder: 1,
    parentId: _expHousing,
  ),
  SeedCategory(
    tempId: 'sub_internet',
    name: 'Internet & Phone',
    type: CategoryType.expense,
    iconEmoji: '\u{1F4F6}',
    colorHex: '#3498DB',
    sortOrder: 2,
    parentId: _expHousing,
  ),

  // Medical children
  SeedCategory(
    tempId: 'sub_doctor',
    name: 'Doctor',
    type: CategoryType.expense,
    iconEmoji: '\u{1FA7A}',
    colorHex: '#E91E63',
    sortOrder: 0,
    parentId: _expMedical,
  ),
  SeedCategory(
    tempId: 'sub_pharmacy',
    name: 'Pharmacy',
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
/// Idempotent — skips if categories already exist.
Future<void> seedCategories(Isar isar) async {
  final count = await isar.categorys.count();
  if (count > 0) return;

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
