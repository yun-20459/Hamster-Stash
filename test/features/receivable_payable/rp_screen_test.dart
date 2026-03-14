import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_repository.dart';
import 'package:hamster_stash/features/receivable_payable/presentation/rp_providers.dart';
import 'package:hamster_stash/features/receivable_payable/presentation/rp_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockRPRepository extends Mock implements RPRepository {}

void main() {
  late MockRPRepository mockRepo;

  setUp(() {
    mockRepo = MockRPRepository();
  });

  Widget buildWidget({List<ReceivablePayable>? items}) {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async =>
          items ??
          [
            ReceivablePayable()
              ..id = 1
              ..counterparty = '小明'
              ..amount = 3000
              ..paidAmount = 1000
              ..type = ReceivablePayableType.receivable
              ..status = ReceivablePayableStatus.partiallyPaid
              ..createdAt = DateTime(2026),
          ],
    );

    return ProviderScope(
      overrides: [rpRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: RPScreen()),
    );
  }

  group('RPScreen', () {
    testWidgets('given items, then shows counterparty name', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('小明'), findsOneWidget);
    });

    testWidgets('given items, then shows amount info', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('3,000'), findsWidgets);
    });

    testWidgets('given partially paid item, then shows status badge', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('部分收付'), findsOneWidget);
    });

    testWidgets('given receivable item, then shows collect button', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('收款'), findsOneWidget);
    });

    testWidgets('given no items, then shows empty message', (tester) async {
      await tester.pumpWidget(buildWidget(items: []));
      await tester.pumpAndSettle();

      expect(find.text('尚未有應收/應付紀錄'), findsOneWidget);
    });

    testWidgets('given rp screen, then shows add button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('given items, then shows balance header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('應收'), findsWidgets);
      expect(find.text('應付'), findsWidgets);
      expect(find.text('淨額'), findsOneWidget);
    });
  });
}
