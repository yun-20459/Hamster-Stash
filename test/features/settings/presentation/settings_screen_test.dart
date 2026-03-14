import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamster_stash/features/settings/presentation/settings_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const ProviderScope(child: MaterialApp(home: SettingsScreen()));
  }

  group('SettingsScreen', () {
    testWidgets('given settings page, then shows section headers', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('一般'), findsOneWidget);
      expect(find.text('資料'), findsOneWidget);
    });

    testWidgets('given settings page, then shows general menu items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('分類管理'), findsOneWidget);
      expect(find.text('帳戶管理'), findsOneWidget);
      expect(find.text('週期性交易'), findsOneWidget);
    });

    testWidgets('given settings page, then shows data menu items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('匯出資料'), findsOneWidget);
      expect(find.text('匯率設定'), findsOneWidget);
    });

    testWidgets('given settings page, then shows about section items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final listView = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(
        find.text('隱私鎖'),
        200,
        scrollable: listView,
      );
      expect(find.text('隱私鎖'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('深色模式'),
        200,
        scrollable: listView,
      );
      expect(find.text('深色模式'), findsOneWidget);
    });

    testWidgets('given about tapped, when dialog opens, then shows app info', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final listView = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(
        find.text("Hamster's Stash v1.0.0"),
        300,
        scrollable: listView,
      );
      await tester.tap(find.text("Hamster's Stash v1.0.0"));
      await tester.pumpAndSettle();

      expect(find.text('倉鼠小金庫 — 你的可愛記帳夥伴'), findsOneWidget);
    });

    testWidgets('given settings page, then dark mode shows coming soon', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final listView = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(
        find.text('即將推出'),
        200,
        scrollable: listView,
      );
      expect(find.text('即將推出'), findsOneWidget);
    });
  });
}
