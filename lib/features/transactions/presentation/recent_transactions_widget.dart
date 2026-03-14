import 'package:flutter/material.dart';

import 'package:hamster_stash/core/theme/app_colors.dart';

/// Mock transaction for display — will be replaced with
/// real data in Phase 3.
class _MockTxn {
  const _MockTxn({
    required this.category,
    required this.emoji,
    required this.amount,
    required this.isExpense,
    required this.note,
    required this.date,
  });

  final String category;
  final String emoji;
  final double amount;
  final bool isExpense;
  final String note;
  final String date;
}

const _mockTxns = [
  _MockTxn(
    category: '午餐',
    emoji: '\u{1F35C}',
    amount: 120,
    isExpense: true,
    note: '公司附近拉麵',
    date: '03/13',
  ),
  _MockTxn(
    category: '薪水',
    emoji: '\u{1F4B0}',
    amount: 45000,
    isExpense: false,
    note: '3月薪資',
    date: '03/10',
  ),
  _MockTxn(
    category: '交通',
    emoji: '\u{1F68B}',
    amount: 1280,
    isExpense: true,
    note: '悠遊卡加值',
    date: '03/08',
  ),
  _MockTxn(
    category: '購物',
    emoji: '\u{1F6D2}',
    amount: 899,
    isExpense: true,
    note: 'UNIQLO 上衣',
    date: '03/05',
  ),
  _MockTxn(
    category: '利息',
    emoji: '\u{1F3E6}',
    amount: 58,
    isExpense: false,
    note: '活存利息',
    date: '03/01',
  ),
];

/// Recent transactions section for the overview page.
class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近交易', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final txn in _mockTxns) _TransactionTile(txn: txn),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn});

  final _MockTxn txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sign = txn.isExpense ? '-' : '+';
    final color = txn.isExpense ? AppColors.expense : AppColors.income;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(txn.emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(txn.category, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        '${txn.date}  ${txn.note}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        '$sign NT\$ ${_fmt(txn.amount)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _fmt(double v) {
  final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  return s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
