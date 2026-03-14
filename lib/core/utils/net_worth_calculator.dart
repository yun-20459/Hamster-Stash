import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';

/// Result of a net worth calculation.
class NetWorthResult {
  const NetWorthResult({
    required this.currentAssets,
    required this.shortTermAssets,
    required this.longTermAssets,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  /// Sum of AssetTerm.current accounts with positive balance.
  final double currentAssets;

  /// Sum of AssetTerm.shortTerm accounts with positive balance.
  final double shortTermAssets;

  /// Sum of AssetTerm.longTerm accounts with positive balance.
  final double longTermAssets;

  /// currentAssets + shortTermAssets + longTermAssets
  final double totalAssets;

  /// Absolute value of negative credit card balances.
  final double totalLiabilities;

  /// totalAssets - totalLiabilities
  final double netWorth;
}

/// Calculates net worth from a list of accounts.
///
/// Multi-currency note: callers must convert balances to a
/// single base currency before calling this function.
/// The [exchangeRates] map provides conversion factors
/// (e.g. {'USD': 31.5, 'JPY': 0.21, 'TWD': 1.0}).
NetWorthResult calculateNetWorth(
  List<Account> accounts, {
  Map<String, double> exchangeRates = const {'TWD': 1.0},
  String baseCurrency = 'TWD',
}) {
  var currentAssets = 0.0;
  var shortTermAssets = 0.0;
  var longTermAssets = 0.0;
  var liabilities = 0.0;

  for (final acct in accounts) {
    if (acct.isArchived) continue;

    final currency = acct.currency ?? baseCurrency;
    final rate = exchangeRates[currency] ?? 1.0;
    final balanceInBase = acct.balance * rate;

    // Credit cards with negative balance = liability
    if (acct.type == AccountType.creditCard && acct.balance < 0) {
      liabilities += balanceInBase.abs();
      continue;
    }

    // Only count positive balances as assets
    if (balanceInBase <= 0) continue;

    switch (acct.assetTerm) {
      case AssetTerm.current:
        currentAssets += balanceInBase;
      case AssetTerm.shortTerm:
        shortTermAssets += balanceInBase;
      case AssetTerm.longTerm:
        longTermAssets += balanceInBase;
    }
  }

  final totalAssets = currentAssets + shortTermAssets + longTermAssets;
  return NetWorthResult(
    currentAssets: currentAssets,
    shortTermAssets: shortTermAssets,
    longTermAssets: longTermAssets,
    totalAssets: totalAssets,
    totalLiabilities: liabilities,
    netWorth: totalAssets - liabilities,
  );
}
