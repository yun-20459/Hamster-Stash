import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/utils/net_worth_calculator.dart';

Account _makeAccount({
  int id = 1,
  String name = 'Test',
  AccountType type = AccountType.bank,
  double balance = 0,
  String currency = 'TWD',
  AssetTerm assetTerm = AssetTerm.current,
  bool isArchived = false,
}) {
  return Account()
    ..id = id
    ..name = name
    ..type = type
    ..balance = balance
    ..currency = currency
    ..assetTerm = assetTerm
    ..isArchived = isArchived
    ..createdAt = DateTime(2026);
}

void main() {
  group('Net worth calculation', () {
    // ─── Test Case 1: Single TWD account ───
    // Bank A: TWD 125,000 (current)
    // Expected: total = 125,000, net = 125,000
    test('given single TWD bank account, '
        'when calculated, '
        'then net worth equals balance', () {
      final accounts = [_makeAccount(name: 'Bank A', balance: 125000)];

      final result = calculateNetWorth(accounts);

      expect(result.currentAssets, 125000);
      expect(result.shortTermAssets, 0);
      expect(result.longTermAssets, 0);
      expect(result.totalAssets, 125000);
      expect(result.totalLiabilities, 0);
      expect(result.netWorth, 125000);
    });

    // ─── Test Case 2: Mixed asset terms, no liabilities ───
    // Cash:     TWD  3,200 (current)
    // Bank:     TWD 80,000 (current)
    // Stock:    TWD 50,000 (shortTerm)
    // Property: TWD 8,500,000 (longTerm)
    // Expected: current=83,200 short=50,000 long=8,500,000
    //           total=8,633,200 net=8,633,200
    test('given mixed asset terms no liabilities, '
        'when calculated, '
        'then subtotals match', () {
      final accounts = [
        _makeAccount(name: 'Cash', type: AccountType.cash, balance: 3200),
        _makeAccount(id: 2, name: 'Bank', balance: 80000),
        _makeAccount(
          id: 3,
          name: 'Stock',
          type: AccountType.investment,
          balance: 50000,
          assetTerm: AssetTerm.shortTerm,
        ),
        _makeAccount(
          id: 4,
          name: 'Property',
          type: AccountType.other,
          balance: 8500000,
          assetTerm: AssetTerm.longTerm,
        ),
      ];

      final result = calculateNetWorth(accounts);

      expect(result.currentAssets, 83200);
      expect(result.shortTermAssets, 50000);
      expect(result.longTermAssets, 8500000);
      expect(result.totalAssets, 8633200);
      expect(result.totalLiabilities, 0);
      expect(result.netWorth, 8633200);
    });

    // ─── Test Case 3: With credit card liability ───
    // Bank:  TWD 100,000 (current)
    // CC:    TWD -15,000 (current, creditCard)
    // Expected: total=100,000 liabilities=15,000 net=85,000
    test('given credit card liability, '
        'when calculated, '
        'then net worth subtracts liability', () {
      final accounts = [
        _makeAccount(name: 'Bank', balance: 100000),
        _makeAccount(
          id: 2,
          name: 'Credit Card',
          type: AccountType.creditCard,
          balance: -15000,
        ),
      ];

      final result = calculateNetWorth(accounts);

      expect(result.currentAssets, 100000);
      expect(result.totalLiabilities, 15000);
      expect(result.netWorth, 85000);
    });

    // ─── Test Case 4: Multi-currency ───
    // Bank TWD:   125,000 (current)
    // Firstrade:  USD 8,520.50 (shortTerm) × 31.5 = 268,395.75
    // Cash JPY:   500,000 (current) × 0.21 = 105,000
    // CC TWD:     -12,000 (current)
    // Expected:
    //   current = 125,000 + 105,000 = 230,000
    //   short   = 268,395.75
    //   total   = 498,395.75
    //   liab    = 12,000
    //   net     = 486,395.75
    test('given multi-currency accounts, '
        'when calculated with exchange rates, '
        'then converts correctly', () {
      final accounts = [
        _makeAccount(name: 'Bank TWD', balance: 125000),
        _makeAccount(
          id: 2,
          name: 'Firstrade',
          type: AccountType.investment,
          balance: 8520.50,
          currency: 'USD',
          assetTerm: AssetTerm.shortTerm,
        ),
        _makeAccount(
          id: 3,
          name: 'Cash JPY',
          type: AccountType.cash,
          balance: 500000,
          currency: 'JPY',
        ),
        _makeAccount(
          id: 4,
          name: 'Credit Card',
          type: AccountType.creditCard,
          balance: -12000,
        ),
      ];

      final rates = {'TWD': 1.0, 'USD': 31.5, 'JPY': 0.21};
      final result = calculateNetWorth(accounts, exchangeRates: rates);

      expect(result.currentAssets, closeTo(230000, 0.01));
      expect(result.shortTermAssets, closeTo(268395.75, 0.01));
      expect(result.longTermAssets, 0);
      expect(result.totalAssets, closeTo(498395.75, 0.01));
      expect(result.totalLiabilities, 12000);
      expect(result.netWorth, closeTo(486395.75, 0.01));
    });

    // ─── Test Case 5: All terms + multiple liabilities ───
    // Cash TWD:      50,000 (current)
    // Savings TWD:   200,000 (current)
    // Stock USD:     5,000 (shortTerm) × 31.5 = 157,500
    // ETF USD:       10,000 (longTerm) × 31.5 = 315,000
    // Property TWD:  6,000,000 (longTerm)
    // CC-A TWD:      -8,000 (current)
    // CC-B TWD:      -25,000 (current)
    // Expected:
    //   current = 250,000
    //   short   = 157,500
    //   long    = 6,315,000
    //   total   = 6,722,500
    //   liab    = 33,000
    //   net     = 6,689,500
    test('given complex portfolio, '
        'when calculated, '
        'then all subtotals correct', () {
      final accounts = [
        _makeAccount(name: 'Cash', type: AccountType.cash, balance: 50000),
        _makeAccount(id: 2, name: 'Savings', balance: 200000),
        _makeAccount(
          id: 3,
          name: 'Stock',
          type: AccountType.investment,
          balance: 5000,
          currency: 'USD',
          assetTerm: AssetTerm.shortTerm,
        ),
        _makeAccount(
          id: 4,
          name: 'ETF',
          type: AccountType.investment,
          balance: 10000,
          currency: 'USD',
          assetTerm: AssetTerm.longTerm,
        ),
        _makeAccount(
          id: 5,
          name: 'Property',
          type: AccountType.other,
          balance: 6000000,
          assetTerm: AssetTerm.longTerm,
        ),
        _makeAccount(
          id: 6,
          name: 'CC-A',
          type: AccountType.creditCard,
          balance: -8000,
        ),
        _makeAccount(
          id: 7,
          name: 'CC-B',
          type: AccountType.creditCard,
          balance: -25000,
        ),
      ];

      final rates = {'TWD': 1.0, 'USD': 31.5};
      final result = calculateNetWorth(accounts, exchangeRates: rates);

      expect(result.currentAssets, 250000);
      expect(result.shortTermAssets, 157500);
      expect(result.longTermAssets, 6315000);
      expect(result.totalAssets, 6722500);
      expect(result.totalLiabilities, 33000);
      expect(result.netWorth, 6689500);
    });

    // ─── Test Case 6: Archived accounts excluded ───
    test('given archived account, '
        'when calculated, '
        'then excluded from totals', () {
      final accounts = [
        _makeAccount(name: 'Active', balance: 50000),
        _makeAccount(id: 2, name: 'Old', balance: 30000, isArchived: true),
      ];

      final result = calculateNetWorth(accounts);

      expect(result.totalAssets, 50000);
      expect(result.netWorth, 50000);
    });

    // ─── Test Case 7: Zero balance accounts ───
    test('given zero balance account, '
        'when calculated, '
        'then excluded from assets', () {
      final accounts = [
        _makeAccount(name: 'Bank', balance: 100000),
        _makeAccount(id: 2, name: 'Empty'),
      ];

      final result = calculateNetWorth(accounts);

      expect(result.currentAssets, 100000);
      expect(result.totalAssets, 100000);
    });

    // ─── Test Case 8: Only liabilities ───
    test('given only credit card debt, '
        'when calculated, '
        'then net worth is negative', () {
      final accounts = [
        _makeAccount(name: 'CC', type: AccountType.creditCard, balance: -50000),
      ];

      final result = calculateNetWorth(accounts);

      expect(result.totalAssets, 0);
      expect(result.totalLiabilities, 50000);
      expect(result.netWorth, -50000);
    });

    // ─── Test Case 9: Credit card with positive balance ───
    test('given credit card with positive balance (overpayment), '
        'when calculated, '
        'then not counted as liability', () {
      final accounts = [
        _makeAccount(
          name: 'CC Overpaid',
          type: AccountType.creditCard,
          balance: 500,
        ),
      ];

      final result = calculateNetWorth(accounts);

      // Positive CC balance = asset (overpayment), not liability
      expect(result.currentAssets, 500);
      expect(result.totalLiabilities, 0);
      expect(result.netWorth, 500);
    });

    // ─── Test Case 10: Empty account list ───
    test('given no accounts, '
        'when calculated, '
        'then everything is zero', () {
      final result = calculateNetWorth([]);

      expect(result.currentAssets, 0);
      expect(result.shortTermAssets, 0);
      expect(result.longTermAssets, 0);
      expect(result.totalAssets, 0);
      expect(result.totalLiabilities, 0);
      expect(result.netWorth, 0);
    });
  });
}
