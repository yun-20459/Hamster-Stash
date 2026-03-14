import 'package:dio/dio.dart';
import 'package:hamster_stash/features/stock/domain/stock_service.dart';

/// Fetches stock prices from Yahoo Finance chart API.
class YahooStockService implements StockService {
  YahooStockService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://query1.finance.yahoo.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  @override
  Future<StockQuote?> getQuote(String symbol) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v8/finance/chart/$symbol',
        queryParameters: {'interval': '1d', 'range': '1d'},
      );
      final chart = response.data?['chart'] as Map<String, dynamic>?;
      final results = chart?['result'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final meta = first['meta'] as Map<String, dynamic>;
      final price = (meta['regularMarketPrice'] as num?)?.toDouble();
      if (price == null) return null;

      return StockQuote(
        symbol: meta['symbol'] as String? ?? symbol,
        price: price,
        currency: meta['currency'] as String? ?? 'USD',
        name: meta['shortName'] as String?,
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, StockQuote>> getQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return {};
    final results = <String, StockQuote>{};
    for (final symbol in symbols) {
      final quote = await getQuote(symbol);
      if (quote != null) {
        results[symbol] = quote;
      }
    }
    return results;
  }
}
