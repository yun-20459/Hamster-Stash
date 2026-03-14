import 'package:flutter/material.dart';

import 'package:hamster_stash/core/theme/app_colors.dart';

enum EmptyStateType { transactions, accounts, categories, budget }

/// Empty state illustration: hamster staring at an empty
/// safe with a call-to-action message.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.type, super.key});

  final EmptyStateType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _configFor(type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hamster emoji
            const Text('\u{1F439}', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            // Safe emoji
            Text(config.icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(config.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              config.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConfig {
  const _EmptyConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;
}

_EmptyConfig _configFor(EmptyStateType type) {
  switch (type) {
    case EmptyStateType.transactions:
      return const _EmptyConfig(
        icon: '\u{1F4E6}',
        title: '還沒有交易紀錄',
        subtitle: '來記第一筆帳吧！',
      );
    case EmptyStateType.accounts:
      return const _EmptyConfig(
        icon: '\u{1F3E6}',
        title: '還沒有帳戶',
        subtitle: '新增一個帳戶開始管理資產',
      );
    case EmptyStateType.categories:
      return const _EmptyConfig(
        icon: '\u{1F4C1}',
        title: '還沒有分類',
        subtitle: '建立分類來整理你的收支',
      );
    case EmptyStateType.budget:
      return const _EmptyConfig(
        icon: '\u{1F4CA}',
        title: '還沒有預算',
        subtitle: '設定預算幫助控制支出',
      );
  }
}
