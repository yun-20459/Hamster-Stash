import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hamster_stash/core/theme/app_theme.dart';
import 'package:hamster_stash/features/asset_overview/presentation/overview_screen.dart';
import 'package:hamster_stash/features/splash/presentation/splash_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
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
              builder: (context, state) =>
                  const _PlaceholderScreen(title: '記帳', icon: Icons.edit_note),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) =>
                  const _PlaceholderScreen(title: '報表', icon: Icons.bar_chart),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) =>
                  const _PlaceholderScreen(title: '設定', icon: Icons.settings),
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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Coming soon...', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
