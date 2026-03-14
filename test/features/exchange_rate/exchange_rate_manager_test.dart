import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/exchange_rate.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_manager.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_repository.dart';
import 'package:hamster_stash/features/exchange_rate/domain/exchange_rate_service.dart';
import 'package:mocktail/mocktail.dart';

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

class MockExchangeRateService extends Mock implements ExchangeRateService {}

void main() {
  late MockExchangeRateRepository mockRepo;
  late MockExchangeRateService mockService;
  late ExchangeRateManager manager;

  setUpAll(() {
    registerFallbackValue(ExchangeRate());
  });

  setUp(() {
    mockRepo = MockExchangeRateRepository();
    mockService = MockExchangeRateService();
    manager = ExchangeRateManager(repository: mockRepo, service: mockService);
  });

  group('ExchangeRateManager', () {
    group('getRate', () {
      test('given same currency, then returns 1.0', () async {
        final rate = await manager.getRate('TWD', 'TWD');
        expect(rate, 1.0);
        verifyNever(() => mockRepo.getCachedRate(any()));
        verifyNever(() => mockService.fetchRate(any(), any()));
      });

      test('given fresh cache, '
          'then returns cached rate without API call', () async {
        when(() => mockRepo.getCachedRate('USD_TWD')).thenAnswer(
          (_) async => ExchangeRate()
            ..pair = 'USD_TWD'
            ..rate = 31.5
            ..fetchedAt = DateTime.now(),
        );

        final rate = await manager.getRate('USD', 'TWD');

        expect(rate, 31.5);
        verify(() => mockRepo.getCachedRate('USD_TWD')).called(1);
        verifyNever(() => mockService.fetchRate(any(), any()));
      });

      test('given stale cache, '
          'then fetches from API and saves', () async {
        when(() => mockRepo.getCachedRate('USD_TWD')).thenAnswer(
          (_) async => ExchangeRate()
            ..pair = 'USD_TWD'
            ..rate = 30.0
            ..fetchedAt = DateTime.now().subtract(const Duration(minutes: 31)),
        );
        when(
          () => mockService.fetchRate('USD', 'TWD'),
        ).thenAnswer((_) async => 31.5);
        when(() => mockRepo.saveRate(any())).thenAnswer((_) async {});

        final rate = await manager.getRate('USD', 'TWD');

        expect(rate, 31.5);
        verify(() => mockService.fetchRate('USD', 'TWD')).called(1);
        verify(() => mockRepo.saveRate(any())).called(1);
      });

      test('given no cache and no network, '
          'then returns null', () async {
        when(
          () => mockRepo.getCachedRate('USD_TWD'),
        ).thenAnswer((_) async => null);
        when(
          () => mockService.fetchRate('USD', 'TWD'),
        ).thenAnswer((_) async => null);

        final rate = await manager.getRate('USD', 'TWD');

        expect(rate, isNull);
      });

      test('given stale cache and API fails, '
          'then falls back to stale cache', () async {
        when(() => mockRepo.getCachedRate('USD_TWD')).thenAnswer(
          (_) async => ExchangeRate()
            ..pair = 'USD_TWD'
            ..rate = 30.0
            ..fetchedAt = DateTime.now().subtract(const Duration(hours: 2)),
        );
        when(
          () => mockService.fetchRate('USD', 'TWD'),
        ).thenAnswer((_) async => null);

        final rate = await manager.getRate('USD', 'TWD');

        expect(rate, 30.0);
      });
    });

    group('getRatesForBase', () {
      test('given no cache, '
          'then fetches all from API and caches', () async {
        when(() => mockRepo.getCachedRate(any())).thenAnswer((_) async => null);
        when(
          () => mockService.fetchRates('USD', ['TWD', 'JPY']),
        ).thenAnswer((_) async => {'TWD': 31.5, 'JPY': 150.0});
        when(() => mockRepo.saveRate(any())).thenAnswer((_) async {});

        final rates = await manager.getRatesForBase('USD', ['TWD', 'JPY']);

        expect(rates['TWD'], 31.5);
        expect(rates['JPY'], 150.0);
      });
    });
  });
}
