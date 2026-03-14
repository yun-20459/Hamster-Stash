import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamster_stash/core/theme/app_theme.dart';
import 'package:hamster_stash/features/accounts/presentation/add_account_form.dart';
import 'package:hamster_stash/features/asset_overview/presentation/overview_screen.dart';
import 'package:hamster_stash/features/categories/presentation/category_management.dart';
import 'package:hamster_stash/features/reports/presentation/reports_screen.dart';
import 'package:hamster_stash/features/settings/presentation/settings_screen.dart';
import 'package:hamster_stash/features/splash/presentation/splash_screen.dart';
import 'package:hamster_stash/features/transactions/presentation/bookkeeping_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/add-account',
      builder: (context, state) => const AddAccountForm(),
    ),
    GoRoute(
      path: '/category-management',
      builder: (context, state) => const CategoryManagement(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/overview',
              builder: (context, state) => const OverviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookkeeping',
              builder: (context, state) => const BookkeepingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class HamsterStashApp extends StatelessWidget {
  const HamsterStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Hamster's Stash",
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: '總覽',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '記帳'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '報表'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
          ],
        ),
      ),
    );
  }
}
