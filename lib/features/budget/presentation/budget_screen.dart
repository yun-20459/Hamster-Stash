import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/budget.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/budget/domain/budget_calculator.dart';
import 'package:hamster_stash/features/budget/presentation/budget_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(activeBudgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('預算管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('尚未設定預算'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) =>
                _BudgetCard(budget: budgets[index]),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var period = BudgetPeriod.monthly;
    var carryOver = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新增預算'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '預算名稱',
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
                DropdownButtonFormField<BudgetPeriod>(
                  initialValue: period,
                  decoration: const InputDecoration(
                    labelText: '週期',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: BudgetPeriod.weekly,
                      child: Text('每週'),
                    ),
                    DropdownMenuItem(
                      value: BudgetPeriod.monthly,
                      child: Text('每月'),
                    ),
                    DropdownMenuItem(
                      value: BudgetPeriod.yearly,
                      child: Text('每年'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => period = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('結轉餘額'),
                  subtitle: const Text('未用完的預算轉到下期'),
                  value: carryOver,
                  onChanged: (v) => setDialogState(() => carryOver = v),
                  contentPadding: EdgeInsets.zero,
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
                final name = nameCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim());
                if (name.isEmpty || amount == null) return;

                final budget = Budget()
                  ..name = name
                  ..amount = amount
                  ..period = period
                  ..carryOver = carryOver
                  ..startDate = DateTime.now()
                  ..createdAt = DateTime.now();

                final repo = ref.read(budgetRepositoryProvider);
                await repo.add(budget);

                if (ctx.mounted) Navigator.of(ctx).pop();
                ref.invalidate(activeBudgetsProvider);
              },
              child: const Text('新增'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard({required this.budget});

  final Budget budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(budgetSpendingProvider(budget));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: spendingAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (result) => _buildContent(context, result),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BudgetSpendingResult result) {
    final theme = Theme.of(context);
    final color = _statusColor(result.status);
    final periodLabel = _periodLabel(budget.period);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(budget.name, style: theme.textTheme.titleMedium),
            Text(periodLabel, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: result.ratio.clamp(0, 1).toDouble(),
            backgroundColor: AppColors.divider,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NT\$ ${_fmt(result.spent)}'
              ' / NT\$ ${_fmt(result.budget)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${(result.ratio * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (result.isOverBudget)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '超支 NT\$ ${_fmt(result.spent - result.budget)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.expense,
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.normal:
        return AppColors.income;
      case BudgetStatus.warning:
        return Colors.amber;
      case BudgetStatus.exceeded:
        return AppColors.expense;
    }
  }

  String _periodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return '每週';
      case BudgetPeriod.monthly:
        return '每月';
      case BudgetPeriod.yearly:
        return '每年';
    }
  }
}

String _fmt(double v) {
  final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  return s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
