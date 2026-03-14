import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/recurring_rule.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/recurring/presentation/recurring_providers.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(allRecurringRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('週期性交易'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rules) {
          if (rules.isEmpty) {
            return const Center(child: Text('尚未設定週期性交易'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rules.length,
            itemBuilder: (context, index) => _RecurringCard(rule: rules[index]),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var frequency = RecurringFrequency.monthly;
    var txnType = TransactionType.expense;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新增週期性交易'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '金額',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType>(
                  initialValue: txnType,
                  decoration: const InputDecoration(
                    labelText: '類型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('支出'),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('收入'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => txnType = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RecurringFrequency>(
                  initialValue: frequency,
                  decoration: const InputDecoration(
                    labelText: '週期',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: RecurringFrequency.daily,
                      child: Text('每日'),
                    ),
                    DropdownMenuItem(
                      value: RecurringFrequency.weekly,
                      child: Text('每週'),
                    ),
                    DropdownMenuItem(
                      value: RecurringFrequency.monthly,
                      child: Text('每月'),
                    ),
                    DropdownMenuItem(
                      value: RecurringFrequency.yearly,
                      child: Text('每年'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => frequency = v!),
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
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null) return;

                final now = DateTime.now();
                final rule = RecurringRule()
                  ..amount = amount
                  ..transactionType = txnType
                  ..frequency = frequency
                  ..note = noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim()
                  ..startDate = now
                  ..nextExecutionAt = now
                  ..createdAt = now;

                final repo = ref.read(recurringRepositoryProvider);
                await repo.add(rule);

                if (ctx.mounted) Navigator.of(ctx).pop();
                ref.invalidate(allRecurringRulesProvider);
              },
              child: const Text('新增'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({required this.rule});

  final RecurringRule rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.note ?? _typeLabel(rule.transactionType),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NT\$ ${_fmt(rule.amount)}'
                    ' · ${_frequencyLabel(rule.frequency)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (rule.nextExecutionAt != null)
                    Text(
                      '下次執行：${_fmtDate(rule.nextExecutionAt!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Icon(
              rule.isActive ? Icons.check_circle : Icons.pause_circle,
              color: rule.isActive ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return '支出';
      case TransactionType.income:
        return '收入';
      case TransactionType.transfer:
        return '轉帳';
    }
  }

  String _frequencyLabel(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return '每日';
      case RecurringFrequency.weekly:
        return '每週';
      case RecurringFrequency.monthly:
        return '每月';
      case RecurringFrequency.yearly:
        return '每年';
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}

String _fmt(double v) {
  final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  return s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
