import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/category.dart'
    as cat_model;
import 'package:hamster_stash/core/database/collections/transaction.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/core/utils/expression_evaluator.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';
import 'package:hamster_stash/features/categories/presentation/category_picker.dart';
import 'package:hamster_stash/features/transactions/'
    'presentation/number_keypad.dart';
import 'package:hamster_stash/features/transactions/presentation/transaction_providers.dart';

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
        heroTag: 'bookkeeping_fab',
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

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet();

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  int _selectedType = 0; // 0 = expense, 1 = income, 2 = transfer
  String _expression = '';
  final _noteController = TextEditingController();
  cat_model.Category? _selectedCategory;
  int? _selectedAccountId;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(activeAccountsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
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
              Text('新增記帳', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              // Type toggle
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

              // Amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty)
                      Text(
                        _expression,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(
                      _expression.isEmpty
                          ? '0'
                          : evaluateExpression(_expression).toStringAsFixed(0),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Number keypad
              NumberKeypad(onInput: _onKeypadInput),
              const SizedBox(height: 12),

              // Category selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _selectedCategory?.iconEmoji ?? '\u{1F4C1}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(_selectedCategory?.name ?? '選擇分類'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickCategory(context),
              ),

              // Account selector
              accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (accounts) {
                  if (_selectedAccountId == null && accounts.isNotEmpty) {
                    _selectedAccountId = accounts.first.id;
                  }
                  final selected = accounts.where(
                    (a) => a.id == _selectedAccountId,
                  );
                  final name = selected.isNotEmpty
                      ? selected.first.name
                      : '選擇帳戶';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  );
                },
              ),

              // Note
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '備註（選填）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Save
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('儲存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onKeypadInput(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        _expression += key;
      }
    });
  }

  void _pickCategory(BuildContext context) {
    final type = _selectedType == 1
        ? CategoryType.income
        : CategoryType.expense;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SizedBox(
        height: 300,
        child: CategoryPicker(
          type: type,
          onSelected: (cat) {
            setState(() => _selectedCategory = cat);
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = evaluateExpression(_expression);

    final type = switch (_selectedType) {
      1 => TransactionType.income,
      2 => TransactionType.transfer,
      _ => TransactionType.expense,
    };

    final txn = Transaction()
      ..amount = amount
      ..type = type
      ..dateTime = DateTime.now()
      ..categoryId = _selectedCategory?.id
      ..accountId = _selectedAccountId
      ..note = _noteController.text.isEmpty ? null : _noteController.text
      ..createdAt = DateTime.now();

    final txnRepo = ref.read(transactionRepositoryProvider);
    await txnRepo.add(txn);

    // Update account balance
    if (_selectedAccountId != null) {
      final acctRepo = ref.read(accountRepositoryProvider);
      final acct = await acctRepo.getById(_selectedAccountId!);
      if (acct != null) {
        final delta = type == TransactionType.expense ? -amount : amount;
        await acctRepo.updateBalance(_selectedAccountId!, acct.balance + delta);
      }
    }

    ref
      ..invalidate(recentTransactionsProvider)
      ..invalidate(activeAccountsProvider);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('記帳成功')));
      Navigator.of(context).pop();
    }
  }
}
