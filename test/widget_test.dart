import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamster_stash/app.dart';

void main() {
  testWidgets('App shows splash screen on launch', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HamsterStashApp()));

    expect(find.text("Hamster's Stash"), findsOneWidget);
    expect(find.text('倉鼠小金庫'), findsOneWidget);

    // Let the splash timer and animations complete to avoid pending timer error
    await tester.pumpAndSettle(const Duration(milliseconds: 2500));
  });

  testWidgets(
    'given splash screen, when animation completes, then navigates to tabs',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: HamsterStashApp()));

      // Fast-forward past splash delay (2200ms) + animation settling
      await tester.pumpAndSettle(const Duration(milliseconds: 2500));

      // Should now show the bottom navigation tabs
      expect(find.text('總覽'), findsWidgets);
      expect(find.text('記帳'), findsOneWidget);
      expect(find.text('報表'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
    },
  );
}
