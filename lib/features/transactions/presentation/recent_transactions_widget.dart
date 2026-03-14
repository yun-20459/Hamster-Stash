import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/core/widgets/empty_state.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

/// Recent transactions section for the overview page.
/// Reads from [recentTransactionsProvider].
class RecentTransactionsWidget extends ConsumerStatefulWidget {
  const RecentTransactionsWidget({super.key});

  @override
  ConsumerState<RecentTransactionsWidget> createState() =>
      _RecentTransactionsWidgetState();
}

class _RecentTransactionsWidgetState
    extends ConsumerState<RecentTransactionsWidget> {
  int _displayCount = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txnAsync = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近交易', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        txnAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (txns) {
            if (txns.isEmpty) {
              return const EmptyState(type: EmptyStateType.transactions);
            }
            final visible = txns.take(_displayCount).toList();
            return Column(
              children: [
                for (final txn in visible) _TransactionTile(txn: txn),
                if (txns.length > _displayCount)
                  TextButton(
                    onPressed: () {
                      setState(() => _displayCount += 10);
                    },
                    child: const Text('載入更多'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.txn});

  final Transaction txn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isExpense = txn.type == TransactionType.expense;
    final isTransfer = txn.type == TransactionType.transfer;
    final sign = isExpense ? '-' : '+';
    final color = isTransfer
        ? AppColors.secondary
        : (isExpense ? AppColors.expense : AppColors.income);

    final dateStr =
        '${txn.dateTime.month.toString().padLeft(2, '0')}/'
        '${txn.dateTime.day.toString().padLeft(2, '0')}';

    // Build category label: "parent > child" or fallback
    var catLabel = isTransfer ? '轉帳' : (txn.note ?? (isExpense ? '支出' : '收入'));
    String? catEmoji;
    if (!isTransfer) {
      ref.watch(categoryWithParentProvider(txn.categoryId)).whenData((pair) {
        final (child, parent) = pair;
        if (parent != null && child != null) {
          catLabel = '${parent.name} > ${child.name}';
          catEmoji = child.iconEmoji;
        } else if (child != null) {
          catLabel = child.name;
          catEmoji = child.iconEmoji;
        }
      });
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: catEmoji != null
            ? Text(catEmoji!, style: const TextStyle(fontSize: 18))
            : Icon(
                isTransfer
                    ? Icons.swap_horiz
                    : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
                color: color,
              ),
      ),
      title: Text(catLabel, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        txn.note != null ? '$dateStr  ${txn.note}' : dateStr,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        isTransfer
            ? 'NT\$ ${_fmt(txn.amount)}'
            : '$sign NT\$ ${_fmt(txn.amount)}',
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
