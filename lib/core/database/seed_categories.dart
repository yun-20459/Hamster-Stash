import 'package:isar/isar.dart';

import 'collections/category.dart';
import 'enums.dart';

Future<void> seedCategories(Isar isar) async {
  final count = await isar.categorys.count();
  if (count > 0) return; // idempotent: skip if already seeded

  final now = DateTime.now();

  final categories = <Category>[];

  // ── Expense Categories ──

  // Food
  final food = Category()
    ..name = 'Food'
    ..type = CategoryType.expense
    ..iconEmoji = '🍔'
    ..colorHex = '#FF6B35'
    ..isDefault = true
    ..sortOrder = 0
    ..createdAt = now;
  categories.add(food);

  // Transport
  final transport = Category()
    ..name = 'Transport'
    ..type = CategoryType.expense
    ..iconEmoji = '🚗'
    ..colorHex = '#4ECDC4'
    ..isDefault = true
    ..sortOrder = 1
    ..createdAt = now;
  categories.add(transport);

  // Entertainment
  final entertainment = Category()
    ..name = 'Entertainment'
    ..type = CategoryType.expense
    ..iconEmoji = '🎮'
    ..colorHex = '#9B59B6'
    ..isDefault = true
    ..sortOrder = 2
    ..createdAt = now;
  categories.add(entertainment);

  // Shopping
  final shopping = Category()
    ..name = 'Shopping'
    ..type = CategoryType.expense
    ..iconEmoji = '🛒'
    ..colorHex = '#E74C3C'
    ..isDefault = true
    ..sortOrder = 3
    ..createdAt = now;
  categories.add(shopping);

  // Housing
  final housing = Category()
    ..name = 'Housing'
    ..type = CategoryType.expense
    ..iconEmoji = '🏠'
    ..colorHex = '#3498DB'
    ..isDefault = true
    ..sortOrder = 4
    ..createdAt = now;
  categories.add(housing);

  // Medical
  final medical = Category()
    ..name = 'Medical'
    ..type = CategoryType.expense
    ..iconEmoji = '🏥'
    ..colorHex = '#E91E63'
    ..isDefault = true
    ..sortOrder = 5
    ..createdAt = now;
  categories.add(medical);

  // Education
  final education = Category()
    ..name = 'Education'
    ..type = CategoryType.expense
    ..iconEmoji = '📚'
    ..colorHex = '#FF9800'
    ..isDefault = true
    ..sortOrder = 6
    ..createdAt = now;
  categories.add(education);

  // Investment (expense)
  final investmentExp = Category()
    ..name = 'Investment'
    ..type = CategoryType.expense
    ..iconEmoji = '📈'
    ..colorHex = '#2E5090'
    ..isDefault = true
    ..sortOrder = 7
    ..createdAt = now;
  categories.add(investmentExp);

  // Other (expense)
  final otherExp = Category()
    ..name = 'Other'
    ..type = CategoryType.expense
    ..iconEmoji = '📦'
    ..colorHex = '#95A5A6'
    ..isDefault = true
    ..sortOrder = 8
    ..createdAt = now;
  categories.add(otherExp);

  // ── Income Categories ──

  // Salary
  final salary = Category()
    ..name = 'Salary'
    ..type = CategoryType.income
    ..iconEmoji = '💰'
    ..colorHex = '#2ECC71'
    ..isDefault = true
    ..sortOrder = 0
    ..createdAt = now;
  categories.add(salary);

  // Bonus
  final bonus = Category()
    ..name = 'Bonus'
    ..type = CategoryType.income
    ..iconEmoji = '🎁'
    ..colorHex = '#F1C40F'
    ..isDefault = true
    ..sortOrder = 1
    ..createdAt = now;
  categories.add(bonus);

  // Investment Returns
  final investmentReturns = Category()
    ..name = 'Investment Returns'
    ..type = CategoryType.income
    ..iconEmoji = '📊'
    ..colorHex = '#1ABC9C'
    ..isDefault = true
    ..sortOrder = 2
    ..createdAt = now;
  categories.add(investmentReturns);

  // Side Job
  final sideJob = Category()
    ..name = 'Side Job'
    ..type = CategoryType.income
    ..iconEmoji = '💼'
    ..colorHex = '#3498DB'
    ..isDefault = true
    ..sortOrder = 3
    ..createdAt = now;
  categories.add(sideJob);

  // Other (income)
  final otherInc = Category()
    ..name = 'Other'
    ..type = CategoryType.income
    ..iconEmoji = '💵'
    ..colorHex = '#95A5A6'
    ..isDefault = true
    ..sortOrder = 4
    ..createdAt = now;
  categories.add(otherInc);

  // ── Sub-categories (expense) ──

  await isar.writeTxn(() async {
    await isar.categorys.putAll(categories);
  });

  // Now add sub-categories with parent IDs
  final savedCategories = await isar.categorys
      .where()
      .sortBySortOrder()
      .findAll();

  final foodId = savedCategories
      .firstWhere((c) => c.name == 'Food' && c.type == CategoryType.expense)
      .id;
  final transportId = savedCategories
      .firstWhere(
        (c) => c.name == 'Transport' && c.type == CategoryType.expense,
      )
      .id;
  final entertainmentId = savedCategories
      .firstWhere(
        (c) => c.name == 'Entertainment' && c.type == CategoryType.expense,
      )
      .id;
  final shoppingId = savedCategories
      .firstWhere((c) => c.name == 'Shopping' && c.type == CategoryType.expense)
      .id;

  final subCategories = <Category>[
    // Food sub-categories
    Category()
      ..name = 'Groceries'
      ..type = CategoryType.expense
      ..iconEmoji = '🥬'
      ..colorHex = '#FF6B35'
      ..parentId = foodId
      ..sortOrder = 0
      ..createdAt = now,
    Category()
      ..name = 'Dining Out'
      ..type = CategoryType.expense
      ..iconEmoji = '🍽️'
      ..colorHex = '#FF6B35'
      ..parentId = foodId
      ..sortOrder = 1
      ..createdAt = now,
    Category()
      ..name = 'Coffee & Drinks'
      ..type = CategoryType.expense
      ..iconEmoji = '☕'
      ..colorHex = '#FF6B35'
      ..parentId = foodId
      ..sortOrder = 2
      ..createdAt = now,

    // Transport sub-categories
    Category()
      ..name = 'Public Transit'
      ..type = CategoryType.expense
      ..iconEmoji = '🚌'
      ..colorHex = '#4ECDC4'
      ..parentId = transportId
      ..sortOrder = 0
      ..createdAt = now,
    Category()
      ..name = 'Gas'
      ..type = CategoryType.expense
      ..iconEmoji = '⛽'
      ..colorHex = '#4ECDC4'
      ..parentId = transportId
      ..sortOrder = 1
      ..createdAt = now,
    Category()
      ..name = 'Taxi & Ride Share'
      ..type = CategoryType.expense
      ..iconEmoji = '🚕'
      ..colorHex = '#4ECDC4'
      ..parentId = transportId
      ..sortOrder = 2
      ..createdAt = now,

    // Entertainment sub-categories
    Category()
      ..name = 'Movies'
      ..type = CategoryType.expense
      ..iconEmoji = '🎬'
      ..colorHex = '#9B59B6'
      ..parentId = entertainmentId
      ..sortOrder = 0
      ..createdAt = now,
    Category()
      ..name = 'Subscriptions'
      ..type = CategoryType.expense
      ..iconEmoji = '📺'
      ..colorHex = '#9B59B6'
      ..parentId = entertainmentId
      ..sortOrder = 1
      ..createdAt = now,

    // Shopping sub-categories
    Category()
      ..name = 'Clothing'
      ..type = CategoryType.expense
      ..iconEmoji = '👕'
      ..colorHex = '#E74C3C'
      ..parentId = shoppingId
      ..sortOrder = 0
      ..createdAt = now,
    Category()
      ..name = 'Electronics'
      ..type = CategoryType.expense
      ..iconEmoji = '📱'
      ..colorHex = '#E74C3C'
      ..parentId = shoppingId
      ..sortOrder = 1
      ..createdAt = now,
  ];

  await isar.writeTxn(() async {
    await isar.categorys.putAll(subCategories);
  });
}
