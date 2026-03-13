import 'package:flutter/material.dart';

import 'package:hamster_stash/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data — will be replaced with Riverpod providers in Phase 3
// ---------------------------------------------------------------------------

class _MockAccount {
  const _MockAccount({
    required this.name,
    required this.emoji,
    required this.balance,
    required this.currency,
    required this.isCurrent,
  });

  final String name;
  final String emoji;
  final double balance;
  final String currency;
  final bool isCurrent;
}

const _mockAccounts = [
  _MockAccount(
    name: '國泰世華',
    emoji: '\u{1F3E6}',
    balance: 125000,
    currency: 'TWD',
    isCurrent: true,
  ),
  _MockAccount(
    name: 'Firstrade',
    emoji: '\u{1F4C8}',
    balance: 8520.50,
    currency: 'USD',
    isCurrent: true,
  ),
  _MockAccount(
    name: '現金',
    emoji: '\u{1F4B5}',
    balance: 3200,
    currency: 'TWD',
    isCurrent: true,
  ),
  _MockAccount(
    name: '不動產',
    emoji: '\u{1F3E0}',
    balance: 8500000,
    currency: 'TWD',
    isCurrent: false,
  ),
];

// Using a simplified mock exchange rate for display
const _mockUsdToTwd = 31.5;

double get _totalCurrentTwd {
  var total = 0.0;
  for (final a in _mockAccounts) {
    if (!a.isCurrent) continue;
    total += a.currency == 'USD' ? a.balance * _mockUsdToTwd : a.balance;
  }
  return total;
}

double get _totalNonCurrentTwd {
  var total = 0.0;
  for (final a in _mockAccounts) {
    if (a.isCurrent) continue;
    total += a.currency == 'USD' ? a.balance * _mockUsdToTwd : a.balance;
  }
  return total;
}

double get _totalAssetsTwd => _totalCurrentTwd + _totalNonCurrentTwd;

// Mock liabilities (credit card + payables)
const _mockLiabilities = 12000.0;
double get _netWorthTwd => _totalAssetsTwd - _mockLiabilities;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('總覽')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Total assets hero card
          _TotalAssetCard(totalTwd: _totalAssetsTwd),
          const SizedBox(height: 12),

          // Summary row: current / non-current / net worth
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: '短期資產',
                  amount: _totalCurrentTwd,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  label: '長期資產',
                  amount: _totalNonCurrentTwd,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  label: '淨資產',
                  amount: _netWorthTwd,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account list header
          Text('帳戶', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),

          // Account cards
          for (final account in _mockAccounts) ...[
            _AccountCard(account: account),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

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

  final _MockAccount account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = account.isCurrent ? '短期' : '長期';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(account.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(account.name, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          tag,
          style: theme.textTheme.bodySmall?.copyWith(
            color: account.isCurrent ? AppColors.income : AppColors.secondary,
          ),
        ),
        trailing: Text(
          '${account.currency == "USD" ? r"$" : r"NT$"} '
          '${_formatAmount(account.balance)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatAmount(double value) {
  // Simple thousands separator
  final parts = value
      .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
      .split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}
