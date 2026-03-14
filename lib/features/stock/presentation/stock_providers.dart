import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/features/stock/domain/stock_service.dart';

/// Provide the stock service — override in tests with a mock.
final stockServiceProvider = Provider<StockService>((ref) {
  throw UnimplementedError('stockServiceProvider must be overridden');
});

/// Fetch a single stock quote with 300ms debounce.
final stockQuoteProvider = FutureProvider.family<StockQuote?, String>((
  ref,
  symbol,
) async {
  // Debounce: wait 300ms before fetching.
  // If the provider is disposed (symbol changed), this throws
  // and the stale request is discarded.
  await Future<void>.delayed(const Duration(milliseconds: 300));

  final service = ref.watch(stockServiceProvider);
  return service.getQuote(symbol);
});

/// Fetch quotes for multiple symbols.
final stockQuotesProvider =
    FutureProvider.family<Map<String, StockQuote>, List<String>>((
      ref,
      symbols,
    ) {
      final service = ref.watch(stockServiceProvider);
      return service.getQuotes(symbols);
    });
