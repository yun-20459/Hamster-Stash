import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/stock/domain/stock_symbol_utils.dart';

void main() {
  group('normalizeSymbol', () {
    test('given US ticker like TSLA, then returns TSLA', () {
      expect(normalizeSymbol('TSLA'), 'TSLA');
    });

    test('given US ticker like AAPL, then returns AAPL', () {
      expect(normalizeSymbol('AAPL'), 'AAPL');
    });

    test('given pure digits like 2330, then appends .TW', () {
      expect(normalizeSymbol('2330'), '2330.TW');
    });

    test('given 4-digit TW stock 0050, then appends .TW', () {
      expect(normalizeSymbol('0050'), '0050.TW');
    });

    test('given already suffixed 2330.TW, then returns as-is', () {
      expect(normalizeSymbol('2330.TW'), '2330.TW');
    });

    test('given lowercase tsla, then uppercases', () {
      expect(normalizeSymbol('tsla'), 'TSLA');
    });

    test('given mixed case Aapl, then uppercases', () {
      expect(normalizeSymbol('Aapl'), 'AAPL');
    });

    test('given symbol with spaces, then trims', () {
      expect(normalizeSymbol('  TSLA  '), 'TSLA');
    });

    test('given empty string, then returns empty', () {
      expect(normalizeSymbol(''), '');
    });
  });

  group('isLikelyTwStock', () {
    test('given 2330, then returns true', () {
      expect(isLikelyTwStock('2330'), isTrue);
    });

    test('given 0050, then returns true', () {
      expect(isLikelyTwStock('0050'), isTrue);
    });

    test('given TSLA, then returns false', () {
      expect(isLikelyTwStock('TSLA'), isFalse);
    });

    test('given 2330.TW, then returns false (already suffixed)', () {
      expect(isLikelyTwStock('2330.TW'), isFalse);
    });
  });
}
