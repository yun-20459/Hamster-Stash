import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/stock/data/yahoo_stock_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late YahooStockService service;

  setUp(() {
    mockDio = MockDio();
    service = YahooStockService(dio: mockDio);
  });

  group('YahooStockService', () {
    group('getQuote', () {
      test('given successful response, then returns quote', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'chart': {
                'result': [
                  {
                    'meta': {
                      'symbol': 'TSLA',
                      'regularMarketPrice': 250.5,
                      'currency': 'USD',
                      'shortName': 'Tesla Inc',
                    },
                  },
                ],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final quote = await service.getQuote('TSLA');

        expect(quote, isNotNull);
        expect(quote!.symbol, 'TSLA');
        expect(quote.price, 250.5);
        expect(quote.currency, 'USD');
      });

      test('given DioException, then returns null', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions()));

        final quote = await service.getQuote('TSLA');
        expect(quote, isNull);
      });

      test('given null result, then returns null', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'chart': {'result': null},
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final quote = await service.getQuote('INVALID');
        expect(quote, isNull);
      });
    });

    group('getQuotes', () {
      test('given multiple symbols, then returns map', () async {
        // First call for TSLA
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/v8/finance/chart/TSLA',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'chart': {
                'result': [
                  {
                    'meta': {
                      'symbol': 'TSLA',
                      'regularMarketPrice': 250.5,
                      'currency': 'USD',
                    },
                  },
                ],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Second call for 2330.TW
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/v8/finance/chart/2330.TW',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'chart': {
                'result': [
                  {
                    'meta': {
                      'symbol': '2330.TW',
                      'regularMarketPrice': 890.0,
                      'currency': 'TWD',
                    },
                  },
                ],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final quotes = await service.getQuotes(['TSLA', '2330.TW']);

        expect(quotes.length, 2);
        expect(quotes['TSLA']!.price, 250.5);
        expect(quotes['2330.TW']!.price, 890.0);
      });

      test('given empty list, then returns empty map', () async {
        final quotes = await service.getQuotes([]);
        expect(quotes, isEmpty);
      });
    });
  });
}
