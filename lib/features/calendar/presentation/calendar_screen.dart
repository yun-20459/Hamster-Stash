import 'package:flutter/material.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

/// Mock daily spending data for the calendar heatmap.
final _mockDailySpending = <DateTime, double>{
  DateTime(2026, 3): 350,
  DateTime(2026, 3, 3): 1200,
  DateTime(2026, 3, 5): 899,
  DateTime(2026, 3, 8): 1280,
  DateTime(2026, 3, 10): -45000, // income (negative = net)
  DateTime(2026, 3, 13): 120,
};

/// Calendar view with daily spending heatmap and
/// transaction details on tap.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime(2026, 3, 13);
  DateTime _selectedDay = DateTime(2026, 3, 13);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          calendarBuilders: CalendarBuilders(
            defaultBuilder: _dayBuilder,
            todayBuilder: _dayBuilder,
            selectedBuilder: (ctx, day, focused) {
              return _dayCell(day, isSelected: true);
            },
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
        _buildDayDetail(),
      ],
    );
  }

  Widget? _dayBuilder(BuildContext ctx, DateTime day, DateTime focused) {
    return _dayCell(day);
  }

  Widget _dayCell(DateTime day, {bool isSelected = false}) {
    final key = DateTime(day.year, day.month, day.day);
    final spending = _mockDailySpending[key];
    final hasData = spending != null;

    Color bg;
    if (isSelected) {
      bg = AppColors.primary;
    } else if (hasData && spending > 0) {
      // Heatmap: higher spending = darker red
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

  Widget _buildDayDetail() {
    final key = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final spending = _mockDailySpending[key];

    if (spending == null) {
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

    final isIncome = spending < 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (isIncome ? AppColors.income : AppColors.expense)
            .withValues(alpha: 0.15),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? AppColors.income : AppColors.expense,
        ),
      ),
      title: Text(isIncome ? '收入' : '支出'),
      trailing: Text(
        'NT\$ ${spending.abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: isIncome ? AppColors.income : AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
