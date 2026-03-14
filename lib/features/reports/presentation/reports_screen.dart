import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

/// Provider that fetches current month's expense transactions
/// grouped by category.
final _monthlyExpensesProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1);
  final all = await repo.getByDateRange(start, end);
  return all.where((t) => t.type == TransactionType.expense).toList();
});

/// Aggregated spending data per category.
class _CategorySpending {
  _CategorySpending({
    required this.name,
    required this.emoji,
    required this.amount,
    required this.color,
  });

  final String name;
  final String emoji;
  final double amount;
  final Color color;
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(_monthlyExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('報表')),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('本月沒有支出紀錄'));
          }
          return _ReportsBody(expenses: expenses);
        },
      ),
    );
  }
}

class _ReportsBody extends ConsumerStatefulWidget {
  const _ReportsBody({required this.expenses});

  final List<Transaction> expenses;

  @override
  ConsumerState<_ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends ConsumerState<_ReportsBody> {
  List<_CategorySpending>? _spending;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final catRepo = ref.read(categoryRepositoryProvider);

    // Group by categoryId
    final grouped = <int, double>{};
    for (final txn in widget.expenses) {
      final catId = txn.categoryId ?? 0;
      grouped[catId] = (grouped[catId] ?? 0) + txn.amount;
    }

    // Resolve category names
    final result = <_CategorySpending>[];
    for (final entry in grouped.entries) {
      final cat = await catRepo.getById(entry.key);
      result.add(
        _CategorySpending(
          name: cat?.name ?? 'Other',
          emoji: cat?.iconEmoji ?? '\u{1F4E6}',
          amount: entry.value,
          color: _parseColor(cat?.colorHex),
        ),
      );
    }

    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));

    if (mounted) setState(() => _spending = result);
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.length < 7) return const Color(0xFF95A5A6);
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) return const Color(0xFF95A5A6);
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_spending == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final spending = _spending!;
    final total = spending.fold<double>(0, (s, c) => s + c.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: spending.map((c) {
                final pct = c.amount / total * 100;
                return PieChartSectionData(
                  value: c.amount,
                  color: c.color,
                  radius: 50,
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('分類明細', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final c in spending) _CategoryRow(category: c, total: total),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.total});

  final _CategorySpending category;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = category.amount / total * 100;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.15),
        child: Text(category.emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(category.name, style: theme.textTheme.bodyMedium),
      subtitle: LinearProgressIndicator(
        value: category.amount / total,
        color: category.color,
        backgroundColor: category.color.withValues(alpha: 0.1),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'NT\$ ${_fmt(category.amount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text('${pct.toStringAsFixed(1)}%', style: theme.textTheme.bodySmall),
        ],
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
