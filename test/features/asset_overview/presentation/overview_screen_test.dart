import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamster_stash/features/asset_overview/presentation/overview_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const ProviderScope(child: MaterialApp(home: OverviewScreen()));
  }

  group('OverviewScreen', () {
    testWidgets('given overview page, then shows total asset card', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('總資產'), findsOneWidget);
      expect(find.textContaining(r'NT$'), findsWidgets);
    });

    testWidgets(
      'given overview page, then shows current, non-current, and net worth summary cards',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('短期資產'), findsOneWidget);
        expect(find.text('長期資產'), findsOneWidget);
        expect(find.text('淨資產'), findsOneWidget);
      },
    );

    testWidgets('given overview page, then shows account list header', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('帳戶'), findsOneWidget);
    });

    testWidgets('given mock accounts, then shows all 4 account cards', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final listView = find.byType(Scrollable).first;

      expect(find.text('國泰世華'), findsOneWidget);
      expect(find.text('Firstrade'), findsOneWidget);
      expect(find.text('現金'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('不動產'),
        200,
        scrollable: listView,
      );
      expect(find.text('不動產'), findsOneWidget);
    });

    testWidgets(
      'given current and non-current accounts, then shows correct asset term tags',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final listView = find.byType(Scrollable).first;

        expect(find.text('短期'), findsAtLeast(1));

        await tester.scrollUntilVisible(
          find.text('長期'),
          200,
          scrollable: listView,
        );
        expect(find.text('長期'), findsAtLeast(1));
      },
    );
  });
}
