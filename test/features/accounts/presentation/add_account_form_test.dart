import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/features/accounts/domain/account_repository.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/accounts/presentation/add_account_form.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class FakeAccount extends Fake implements Account {}

void main() {
  late MockAccountRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
  });

  setUp(() {
    mockRepo = MockAccountRepository();
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [accountRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: Scaffold(body: AddAccountForm())),
    );
  }

  group('AddAccountForm', () {
    testWidgets('given form displayed, '
        'then shows name, currency, and balance fields', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('帳戶名稱'), findsOneWidget);
      expect(find.text('幣別'), findsOneWidget);
      expect(find.text('初始餘額'), findsOneWidget);
    });

    testWidgets('given form displayed, '
        'then shows account type selector', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('帳戶類型'), findsOneWidget);
    });

    testWidgets('given form displayed, '
        'then shows save button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('儲存'), findsOneWidget);
    });

    testWidgets('given empty name, '
        'when save tapped, '
        'then shows validation error', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      expect(find.text('請輸入帳戶名稱'), findsOneWidget);
    });

    testWidgets('given valid form, '
        'when save tapped, '
        'then calls repository add', (tester) async {
      when(() => mockRepo.add(any())).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.byType(TextFormField).first, 'My Bank');
      await tester.enterText(find.byType(TextFormField).last, '5000');
      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.add(any())).called(1);
    });
  });
}
