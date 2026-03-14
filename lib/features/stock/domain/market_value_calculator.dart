import 'package:hamster_stash/features/stock/domain/stock_service.dart';

/// Calculates market value: shares × price × exchangeRate.
///
/// If the quote currency matches [baseCurrency], exchange rate
/// is treated as 1 (no conversion needed).
double calculateMarketValue({
  required double shares,
  required StockQuote quote,
  required double exchangeRate,
  required String baseCurrency,
}) {
  if (shares == 0) return 0;
  final rate = quote.currency == baseCurrency ? 1.0 : exchangeRate;
  return shares * quote.price * rate;
}
