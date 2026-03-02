import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hamster_stash/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HamsterStashApp()));

    expect(find.text('Accounts'), findsWidgets);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
