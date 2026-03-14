import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/features/exchange_rate/data/frankfurter_exchange_rate_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late FrankfurterExchangeRateService service;

  setUp(() {
    mockDio = MockDio();
    service = FrankfurterExchangeRateService(dio: mockDio);
  });

  group('FrankfurterExchangeRateService', () {
    group('fetchRate', () {
      test('given successful response, then returns rate', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/latest',
            queryParameters: {'from': 'USD', 'to': 'TWD'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'rates': {'TWD': 31.5},
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final rate = await service.fetchRate('USD', 'TWD');
        expect(rate, 31.5);
      });

      test('given DioException, then returns null', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/latest',
            queryParameters: {'from': 'USD', 'to': 'TWD'},
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions()));

        final rate = await service.fetchRate('USD', 'TWD');
        expect(rate, isNull);
      });

      test('given null rates in response, then returns null', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/latest',
            queryParameters: {'from': 'USD', 'to': 'TWD'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final rate = await service.fetchRate('USD', 'TWD');
        expect(rate, isNull);
      });
    });

    group('fetchRates', () {
      test('given successful response, '
          'then returns map of rates', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/latest',
            queryParameters: {'from': 'USD', 'to': 'TWD,JPY'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'rates': {'TWD': 31.5, 'JPY': 150.0},
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final rates = await service.fetchRates('USD', ['TWD', 'JPY']);

        expect(rates['TWD'], 31.5);
        expect(rates['JPY'], 150.0);
      });

      test('given empty targets, then returns empty map', () async {
        final rates = await service.fetchRates('USD', []);
        expect(rates, isEmpty);
      });
    });
  });
}
