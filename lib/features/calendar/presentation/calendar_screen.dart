import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';
import 'package:table_calendar/table_calendar.dart';

/// Provider for monthly transactions.
final _monthTransactionsProvider =
    FutureProvider.family<List<Transaction>, DateTime>((ref, month) {
      final repo = ref.watch(transactionRepositoryProvider);
      final start = DateTime(month.year, month.month);
      final end = DateTime(month.year, month.month + 1);
      return repo.getByDateRange(start, end);
    });

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthKey = DateTime(_focusedDay.year, _focusedDay.month);
    final txnAsync = ref.watch(_monthTransactionsProvider(monthKey));

    // Build daily spending map from transactions
    final dailySpending = <DateTime, double>{};
    final dayTransactions = <Transaction>[];

    txnAsync.whenData((txns) {
      for (final txn in txns) {
        final key = DateTime(
          txn.dateTime.year,
          txn.dateTime.month,
          txn.dateTime.day,
        );
        final amount = txn.type == TransactionType.income
            ? -txn.amount
            : txn.amount;
        dailySpending[key] = (dailySpending[key] ?? 0) + amount;
      }

      // Filter transactions for selected day
      final selectedKey = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      dayTransactions.addAll(
        txns.where(
          (t) =>
              t.dateTime.year == selectedKey.year &&
              t.dateTime.month == selectedKey.month &&
              t.dateTime.day == selectedKey.day,
        ),
      );
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TableCalendar<void>(
          firstDay: DateTime(2025),
          lastDay: DateTime(2027),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (ctx, day, focused) => _dayCell(day, dailySpending),
            todayBuilder: (ctx, day, focused) => _dayCell(day, dailySpending),
            selectedBuilder: (ctx, day, focused) =>
                _dayCell(day, dailySpending, isSelected: true),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        ),
        const Divider(height: 32),
        Text('當日交易', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildDayDetail(dayTransactions, dailySpending),
      ],
    );
  }

  Widget _dayCell(
    DateTime day,
    Map<DateTime, double> dailySpending, {
    bool isSelected = false,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final spending = dailySpending[key];
    final hasData = spending != null;

    Color bg;
    if (isSelected) {
      bg = AppColors.primary;
    } else if (hasData && spending > 0) {
      final intensity = (spending / 2000).clamp(0.15, 0.6);
      bg = AppColors.expense.withValues(alpha: intensity);
    } else if (hasData && spending < 0) {
      bg = AppColors.income.withValues(alpha: 0.25);
    } else {
      bg = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDayDetail(
    List<Transaction> transactions,
    Map<DateTime, double> dailySpending,
  ) {
    final key = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final spending = dailySpending[key];

    if (spending == null && transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '這天沒有交易記錄',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.divider),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final txn in transactions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor:
                  (txn.type == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense)
                      .withValues(alpha: 0.15),
              child: Icon(
                txn.type == TransactionType.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: txn.type == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),
            title: Text(
              txn.note ?? (txn.type == TransactionType.income ? '收入' : '支出'),
            ),
            trailing: Text(
              'NT\$ ${txn.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: txn.type == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
