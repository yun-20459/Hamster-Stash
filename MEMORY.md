# Hamster's Stash — Project Memory

## Overview
Hamster's Stash is a personal finance management app built with Flutter. It helps users track accounts, transactions, budgets, and generate financial reports.

## Tech Stack
| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.2 / Dart 3.11.0 |
| State Management | flutter_riverpod (no codegen) |
| Database | Isar v3 (local, encrypted) |
| Navigation | go_router (StatefulShellRoute, 4 tabs) |
| Network | dio + dio_smart_retry |
| Charts | fl_chart |
| Auth | local_auth (biometric) |
| Scanning | camera + google_mlkit_barcode_scanning |
| Testing | mocktail, flutter_test, integration_test |
| Linting | very_good_analysis |

## Known Constraints
- **riverpod_generator and riverpod_lint are NOT installed** — Isar v3's `isar_generator` depends on `analyzer <6.0.0` and `source_gen ^1.2.2`, which conflicts with modern riverpod codegen packages. Use Riverpod manually (no `@riverpod` annotation codegen).
- **mockito is NOT installed** — same analyzer conflict. Use `mocktail` instead.
- **build_runner pinned to ^2.4.13** — required for isar_generator compatibility.

## Git Workflow
- **Never commit directly to `main`.**
- Commit after completing each logical task.
- All feature work merges into `develop` first, then `develop` → `main` via PR.

### Branch Naming
- **Erin:** `feature/*` branches (e.g. `feature/transaction-crud`, `feature/budget-logic`)
- **Emma:** `feature/emma-*` branches (e.g. `feature/emma-splash`, `feature/emma-category-picker`)

### Merge Flow
- Emma completes work on `feature/emma-*` → Erin reviews the PR → merge to `develop`
- This ensures code quality and consistency before anything reaches `develop`.

## Project Structure
```
lib/
  main.dart                    # Entry point, ProviderScope
  app.dart                     # MaterialApp.router, go_router, 4-tab nav
  core/
    constants/api_constants.dart
    database/
      enums.dart               # AccountType, TransactionType, CategoryType, etc.
      database_helper.dart     # Isar init with AES-256 encryption
      seed_categories.dart     # Default expense/income categories
      collections/             # Isar @collection models + .g.dart
        account.dart
        transaction.dart       # Indexes: dateTime, categoryId, accountId
        category.dart
        budget.dart
        recurring_rule.dart
        receivable_payable.dart
        manual_valuation.dart
    errors/app_exception.dart  # DatabaseException, NetworkException, AuthException
    extensions/
    theme/
      app_colors.dart          # Primary #D4740A, background #FFF8F0, etc.
      app_theme.dart           # Light theme, typography scale, border radii
    utils/
  features/                    # Feature-first architecture
    accounts/                  # data/ domain/ presentation/
    transactions/
    categories/
    budget/
    recurring/
    reports/
    calendar/
    search/
    data_export/
    asset_overview/
    market_data/
    invoice_scanner/
    exchange_rate/
    receivables_payables/
    auth_lock/
```

Each feature has three layers:
- **data/** — datasources, models, repository implementations
- **domain/** — entities, repository interfaces, use cases
- **presentation/** — providers, screens, widgets

## Database Schema (Isar v3)
7 collections: `Account`, `Transaction`, `Category`, `Budget`, `RecurringRule`, `ReceivablePayable`, `ManualValuation`

8 enums: `AccountType`, `AssetTerm`, `TransactionType`, `CategoryType`, `BudgetPeriod`, `RecurringFrequency`, `ReceivablePayableType`, `ReceivablePayableStatus`

## Theme
- Primary: `#D4740A` (orange)
- Background: `#FFF8F0` (warm white)
- Expense: `#E74C3C` (red)
- Income: `#2ECC71` (green)
- Secondary: `#2E5090` (blue)
- Typography: 28pt bold / 18pt semi / 14pt regular / 12pt caption
- Border radius: 16 / 24 / 999
- Light theme only (dark mode planned for Phase 5)

## Seed Categories
- **Expense (9):** Food, Transport, Entertainment, Shopping, Housing, Medical, Education, Investment, Other
- **Income (5):** Salary, Bonus, Investment Returns, Side Job, Other
- **Sub-categories (10):** Groceries, Dining Out, Coffee & Drinks, Public Transit, Gas, Taxi & Ride Share, Movies, Subscriptions, Clothing, Electronics
- Seeding is idempotent — skips if categories already exist.

## Current Status
Phase 0 (project foundation) is complete. The app builds for web and shows a 4-tab navigation with placeholder screens.
