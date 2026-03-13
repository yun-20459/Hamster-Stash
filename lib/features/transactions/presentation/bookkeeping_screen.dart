import 'package:flutter/material.dart';

import 'package:hamster_stash/core/theme/app_colors.dart';

class BookkeepingScreen extends StatelessWidget {
  const BookkeepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('記帳')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\u{1F4DD}', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('點擊下方按鈕來記帳', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddTransactionSheet(),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet();

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  int _selectedType = 0; // 0 = expense, 1 = income, 2 = transfer

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text('新增記帳', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Type toggle: expense / income / transfer
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('支出')),
                ButtonSegment(value: 1, label: Text('收入')),
                ButtonSegment(value: 2, label: Text('轉帳')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (value) {
                setState(() => _selectedType = value.first);
              },
            ),
            const SizedBox(height: 16),

            // Amount field (placeholder)
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '金額',
                prefixText: _selectedType == 2 ? '' : r'NT$ ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Category selector (placeholder)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.category, color: AppColors.primary),
              ),
              title: const Text('選擇分類'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            // Account selector (placeholder)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('選擇帳戶'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            // Note field
            const TextField(
              decoration: InputDecoration(
                labelText: '備註（選填）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('儲存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
