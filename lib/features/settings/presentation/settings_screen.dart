import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hamster_stash/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // General section
          _SectionHeader(title: '一般', theme: theme),
          _SettingsTile(
            icon: Icons.category,
            title: '分類管理',
            subtitle: '新增、編輯或刪除分類',
            onTap: () => context.push('/category-management'),
          ),
          _SettingsTile(
            icon: Icons.account_balance_wallet,
            title: '帳戶管理',
            subtitle: '新增、編輯或刪除帳戶',
            onTap: () => context.push('/add-account'),
          ),
          _SettingsTile(
            icon: Icons.pie_chart,
            title: '預算管理',
            subtitle: '設定與追蹤預算',
            onTap: () => context.push('/budget-management'),
          ),
          _SettingsTile(
            icon: Icons.repeat,
            title: '週期性交易',
            subtitle: '管理自動記帳規則',
            onTap: () => context.push('/recurring-management'),
          ),
          const Divider(),

          // Data section
          _SectionHeader(title: '資料', theme: theme),
          _SettingsTile(
            icon: Icons.file_download,
            title: '匯出資料',
            subtitle: '將交易紀錄匯出為 CSV',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.currency_exchange,
            title: '匯率設定',
            subtitle: '查看與管理匯率',
            onTap: () {},
          ),
          const Divider(),

          // App section
          _SectionHeader(title: '關於', theme: theme),
          _SettingsTile(
            icon: Icons.lock,
            title: '隱私鎖',
            subtitle: '生物辨識鎖設定',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.dark_mode,
            title: '深色模式',
            subtitle: '即將推出',
            onTap: () {},
            enabled: false,
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: '關於',
            subtitle: "Hamster's Stash v1.0.0",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Hamster's Stash",
                applicationVersion: 'v1.0.0',
                applicationIcon: const Text(
                  '\u{1F439}',
                  style: TextStyle(fontSize: 48),
                ),
                children: [const Text('倉鼠小金庫 — 你的可愛記帳夥伴')],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      enabled: enabled,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
