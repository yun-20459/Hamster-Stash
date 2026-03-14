import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/stock/domain/market_value_calculator.dart';
import 'package:hamster_stash/features/stock/domain/stock_service.dart';

void main() {
  group('calculateMarketValue', () {
    test('given shares and price in same currency, '
        'then returns shares * price', () {
      final result = calculateMarketValue(
        shares: 100,
        quote: const StockQuote(symbol: '2330.TW', price: 890, currency: 'TWD'),
        exchangeRate: 1,
        baseCurrency: 'TWD',
      );
      expect(result, 89000);
    });

    test('given US stock with USD→TWD rate, '
        'then returns shares * price * rate', () {
      final result = calculateMarketValue(
        shares: 10,
        quote: const StockQuote(symbol: 'TSLA', price: 250, currency: 'USD'),
        exchangeRate: 31.5,
        baseCurrency: 'TWD',
      );
      expect(result, 78750);
    });

    test('given stock currency matches base, '
        'then exchange rate is ignored', () {
      final result = calculateMarketValue(
        shares: 5,
        quote: const StockQuote(symbol: '2330.TW', price: 890, currency: 'TWD'),
        exchangeRate: 31.5,
        baseCurrency: 'TWD',
      );
      // currency == baseCurrency, so rate = 1
      expect(result, 4450);
    });

    test('given zero shares, then returns 0', () {
      final result = calculateMarketValue(
        shares: 0,
        quote: const StockQuote(symbol: 'TSLA', price: 250, currency: 'USD'),
        exchangeRate: 31.5,
        baseCurrency: 'TWD',
      );
      expect(result, 0);
    });
  });
}
