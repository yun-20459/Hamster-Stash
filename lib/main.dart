import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/app.dart';
import 'package:hamster_stash/core/database/database_helper.dart';
import 'package:hamster_stash/core/database/seed_categories.dart';
import 'package:hamster_stash/features/accounts/data/isar_account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/budget/data/isar_budget_repository.dart';
import 'package:hamster_stash/features/budget/presentation/budget_providers.dart';
import 'package:hamster_stash/features/categories/data/isar_category_repository.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/exchange_rate/data/frankfurter_exchange_rate_service.dart';
import 'package:hamster_stash/features/receivable_payable/data/isar_rp_repository.dart';
import 'package:hamster_stash/features/receivable_payable/presentation/rp_providers.dart';
import 'package:hamster_stash/features/exchange_rate/data/isar_exchange_rate_repository.dart';
import 'package:hamster_stash/features/exchange_rate/presentation/exchange_rate_providers.dart';
import 'package:hamster_stash/features/stock/data/yahoo_stock_service.dart';
import 'package:hamster_stash/features/stock/presentation/stock_providers.dart';
import 'package:hamster_stash/features/transactions/data/isar_transaction_repository.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await DatabaseHelper.instance;
  await seedCategories(isar);

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
        rpRepositoryProvider.overrideWithValue(IsarRPRepository(isar)),
        exchangeRateRepositoryProvider.overrideWithValue(
          IsarExchangeRateRepository(isar),
        ),
        exchangeRateServiceProvider.overrideWithValue(
          FrankfurterExchangeRateService(),
        ),
        budgetRepositoryProvider.overrideWithValue(IsarBudgetRepository(isar)),
        stockServiceProvider.overrideWithValue(YahooStockService()),
      ],
      child: const HamsterStashApp(),
    ),
  );
}
