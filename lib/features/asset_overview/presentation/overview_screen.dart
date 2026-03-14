import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/core/widgets/empty_state.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/transactions/presentation/recent_transactions_widget.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(activeAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('總覽')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const EmptyState(type: EmptyStateType.accounts);
          }
          return _OverviewBody(accounts: accounts);
        },
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentTotal =
        _sumByTerm(AssetTerm.current) + _sumByTerm(AssetTerm.shortTerm);
    final longTermTotal = _sumByTerm(AssetTerm.longTerm);
    final totalAssets = currentTotal + longTermTotal;

    // Liabilities: credit card balances (negative = owed)
    final liabilities = accounts
        .where((a) => a.type == AccountType.creditCard && a.balance < 0)
        .fold<double>(0, (sum, a) => sum + a.balance.abs());
    final netWorth = totalAssets - liabilities;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _TotalAssetCard(totalTwd: totalAssets),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '短期資產',
                amount: currentTotal,
                color: AppColors.income,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: '長期資產',
                amount: longTermTotal,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: '淨資產',
                amount: netWorth,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('帳戶', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final account in accounts) ...[
          _AccountCard(account: account),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        const RecentTransactionsWidget(),
      ],
    );
  }

  double _sumByTerm(AssetTerm term) {
    return accounts
        .where((a) => a.assetTerm == term && a.balance > 0)
        .fold<double>(0, (sum, a) => sum + a.balance);
  }
}

class _TotalAssetCard extends StatelessWidget {
  const _TotalAssetCard({required this.totalTwd});

  final double totalTwd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '總資產',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NT\$ ${_formatAmount(totalTwd)}',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'NT\$ ${_formatAmount(amount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent =
        account.assetTerm == AssetTerm.current ||
        account.assetTerm == AssetTerm.shortTerm;
    final tag = isCurrent ? '短期' : '長期';
    final currency = account.currency ?? 'TWD';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            account.iconEmoji ?? _defaultEmoji(account.type),
            style: const TextStyle(fontSize: 22),
          ),
        ),
        title: Text(account.name, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          tag,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCurrent ? AppColors.income : AppColors.secondary,
          ),
        ),
        trailing: Text(
          '${currency == "USD" ? r"$" : r"NT$"} '
          '${_formatAmount(account.balance)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _defaultEmoji(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '\u{1F4B5}';
      case AccountType.bank:
        return '\u{1F3E6}';
      case AccountType.creditCard:
        return '\u{1F4B3}';
      case AccountType.eWallet:
        return '\u{1F4F1}';
      case AccountType.investment:
        return '\u{1F4C8}';
      case AccountType.other:
        return '\u{1F4E6}';
    }
  }
}

String _formatAmount(double value) {
  final parts = value
      .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
      .split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}
