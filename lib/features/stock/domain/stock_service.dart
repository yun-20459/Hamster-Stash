/// Result of a stock price query.
class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.price,
    required this.currency,
    this.name,
    this.change,
    this.changePercent,
  });

  final String symbol;
  final double price;
  final String currency;
  final String? name;
  final double? change;
  final double? changePercent;
}

/// Fetches stock prices from a remote API.
abstract class StockService {
  /// Fetch the latest quote for [symbol].
  /// Returns null on failure.
  Future<StockQuote?> getQuote(String symbol);

  /// Fetch quotes for multiple symbols.
  Future<Map<String, StockQuote>> getQuotes(List<String> symbols);
}
