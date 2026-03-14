import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/receivable_payable.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/receivable_payable/domain/rp_calculator.dart';
import 'package:hamster_stash/features/receivable_payable/presentation/rp_providers.dart';

class RPScreen extends ConsumerWidget {
  const RPScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allRPItemsProvider);
    final balanceAsync = ref.watch(rpBalanceSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('應收/應付'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('尚未有應收/應付紀錄'));
          }
          return Column(
            children: [
              balanceAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _BalanceHeader(summary: summary),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _RPCard(
                    item: items[index],
                    onRecordPayment: () =>
                        _showPaymentDialog(context, ref, items[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final counterpartyCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var type = ReceivablePayableType.receivable;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新增應收/應付'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ReceivablePayableType>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: '類型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ReceivablePayableType.receivable,
                      child: Text('應收（別人欠我）'),
                    ),
                    DropdownMenuItem(
                      value: ReceivablePayableType.payable,
                      child: Text('應付（我欠別人）'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: counterpartyCtrl,
                  decoration: const InputDecoration(
                    labelText: '對象',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '金額',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: '備註',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = counterpartyCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim());
                if (name.isEmpty || amount == null) return;

                final now = DateTime.now();
                final item = ReceivablePayable()
                  ..counterparty = name
                  ..amount = amount
                  ..type = type
                  ..note = noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim()
                  ..createdAt = now;

                final repo = ref.read(rpRepositoryProvider);
                await repo.add(item);

                if (ctx.mounted) Navigator.of(ctx).pop();
                ref.invalidate(allRPItemsProvider);
              },
              child: const Text('新增'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    ReceivablePayable item,
  ) {
    final amountCtrl = TextEditingController();
    final remaining = item.amount - item.paidAmount;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item.type == ReceivablePayableType.receivable ? '收款' : '付款',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('剩餘: NT\$ ${_fmt(remaining)}'),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '金額',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final payment = double.tryParse(amountCtrl.text.trim());
              if (payment == null || payment <= 0) return;

              recordPayment(item, payment);
              item.updatedAt = DateTime.now();

              final repo = ref.read(rpRepositoryProvider);
              await repo.update(item);

              if (ctx.mounted) Navigator.of(ctx).pop();
              ref.invalidate(allRPItemsProvider);
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.summary});

  final RPBalanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BalanceColumn(
              label: '應收',
              amount: summary.totalReceivable,
              color: AppColors.income,
            ),
            _BalanceColumn(
              label: '應付',
              amount: summary.totalPayable,
              color: AppColors.expense,
            ),
            _BalanceColumn(
              label: '淨額',
              amount: summary.netBalance,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceColumn extends StatelessWidget {
  const _BalanceColumn({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'NT\$ ${_fmt(amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RPCard extends StatelessWidget {
  const _RPCard({required this.item, required this.onRecordPayment});

  final ReceivablePayable item;
  final VoidCallback onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = item.status == ReceivablePayableStatus.paid;
    final overdue = isOverdue(item, DateTime.now());
    final typeLabel = item.type == ReceivablePayableType.receivable
        ? '應收'
        : '應付';
    final progress = item.amount > 0 ? item.paidAmount / item.amount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.counterparty,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(
                      item.status,
                      overdue,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel(item.status, overdue),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _statusColor(item.status, overdue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$typeLabel · NT\$ ${_fmt(item.amount)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                backgroundColor: AppColors.divider,
                color: isPaid ? AppColors.income : AppColors.expense,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已${item.type == ReceivablePayableType.receivable ? '收' : '付'}'
                  ' NT\$ ${_fmt(item.paidAmount)}'
                  ' / NT\$ ${_fmt(item.amount)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (!isPaid)
                  TextButton(
                    onPressed: onRecordPayment,
                    child: Text(
                      item.type == ReceivablePayableType.receivable
                          ? '收款'
                          : '付款',
                    ),
                  ),
              ],
            ),
            if (item.dueDate != null)
              Text(
                '到期日：${_fmtDate(item.dueDate!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: overdue ? AppColors.expense : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ReceivablePayableStatus status, bool overdue) {
    if (overdue) return AppColors.expense;
    switch (status) {
      case ReceivablePayableStatus.pending:
        return Colors.orange;
      case ReceivablePayableStatus.partiallyPaid:
        return Colors.amber;
      case ReceivablePayableStatus.paid:
        return AppColors.income;
      case ReceivablePayableStatus.overdue:
        return AppColors.expense;
    }
  }

  String _statusLabel(ReceivablePayableStatus status, bool overdue) {
    if (overdue) return '已逾期';
    switch (status) {
      case ReceivablePayableStatus.pending:
        return '待處理';
      case ReceivablePayableStatus.partiallyPaid:
        return '部分收付';
      case ReceivablePayableStatus.paid:
        return '已結清';
      case ReceivablePayableStatus.overdue:
        return '已逾期';
    }
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}'
    '/${d.day.toString().padLeft(2, '0')}';

String _fmt(double v) {
  final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  return s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
