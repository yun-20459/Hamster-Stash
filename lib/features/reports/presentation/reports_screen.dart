import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Mock category spending data for the pie chart.
class _CategorySpending {
  const _CategorySpending({
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

const _mockSpending = [
  _CategorySpending(
    name: '飲食',
    emoji: '\u{1F35C}',
    amount: 8500,
    color: Color(0xFFE74C3C),
  ),
  _CategorySpending(
    name: '交通',
    emoji: '\u{1F68B}',
    amount: 3200,
    color: Color(0xFF3498DB),
  ),
  _CategorySpending(
    name: '購物',
    emoji: '\u{1F6D2}',
    amount: 2800,
    color: Color(0xFFF39C12),
  ),
  _CategorySpending(
    name: '娛樂',
    emoji: '\u{1F3AE}',
    amount: 1500,
    color: Color(0xFF9B59B6),
  ),
  _CategorySpending(
    name: '日用品',
    emoji: '\u{1F9F4}',
    amount: 900,
    color: Color(0xFF1ABC9C),
  ),
];

double get _totalSpending => _mockSpending.fold(0, (s, c) => s + c.amount);

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('報表')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pie chart
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _mockSpending.map((c) {
                  final pct = c.amount / _totalSpending * 100;
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

          // Category detail list
          Text('分類明細', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final c in _mockSpending) _CategoryRow(category: c),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final _CategorySpending category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = category.amount / _totalSpending * 100;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.15),
        child: Text(category.emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(category.name, style: theme.textTheme.bodyMedium),
      subtitle: LinearProgressIndicator(
        value: category.amount / _totalSpending,
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
