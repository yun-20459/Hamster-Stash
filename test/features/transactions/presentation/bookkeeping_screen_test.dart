import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamster_stash/features/transactions/presentation/bookkeeping_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const ProviderScope(child: MaterialApp(home: BookkeepingScreen()));
  }

  group('BookkeepingScreen', () {
    testWidgets('given bookkeeping page, then shows FAB with add icon', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('given bookkeeping page, then shows prompt text', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('點擊下方按鈕來記帳'), findsOneWidget);
    });

    testWidgets(
      'given FAB tapped, when bottom sheet opens, then shows transaction form',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('新增記帳'), findsOneWidget);
        expect(find.text('支出'), findsOneWidget);
        expect(find.text('收入'), findsOneWidget);
        expect(find.text('轉帳'), findsOneWidget);
      },
    );

    testWidgets(
      'given bottom sheet open, then shows amount field and selectors',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('金額'), findsOneWidget);
        expect(find.text('選擇分類'), findsOneWidget);
        expect(find.text('選擇帳戶'), findsOneWidget);
        expect(find.text('備註（選填）'), findsOneWidget);
        expect(find.text('儲存'), findsOneWidget);
      },
    );

    testWidgets(
      'given bottom sheet open, when save tapped, then sheet closes',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('儲存'));
        await tester.pumpAndSettle();

        // Sheet should be dismissed, form title gone
        expect(find.text('新增記帳'), findsNothing);
      },
    );
  });
}
