import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/app.dart';
import 'package:hamster_stash/core/database/database_helper.dart';
import 'package:hamster_stash/features/accounts/data/isar_account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/categories/data/isar_category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/transactions/data/isar_transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await DatabaseHelper.instance;

  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(
          IsarAccountRepository(isar),
        ),
        transactionRepositoryProvider.overrideWithValue(
          IsarTransactionRepository(isar),
        ),
        categoryRepositoryProvider.overrideWithValue(
          IsarCategoryRepository(isar),
        ),
      ],
      child: const HamsterStashApp(),
    ),
  );
}
