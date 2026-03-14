import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/account.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/database/seed_categories.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/accounts/presentation/account_providers.dart';

class AddAccountForm extends ConsumerStatefulWidget {
  const AddAccountForm({super.key});

  @override
  ConsumerState<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends ConsumerState<AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String _currency = 'TWD';
  AccountType _type = AccountType.bank;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('新增帳戶', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '帳戶名稱',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '請輸入帳戶名稱' : null,
          ),
          const SizedBox(height: 12),

          // Account type
          Text('帳戶類型', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AccountType.values.map((t) {
              final selected = t == _type;
              return ChoiceChip(
                label: Text(_accountTypeLabel(t)),
                selected: selected,
                onSelected: (_) => setState(() => _type = t),
                selectedColor: AppColors.primaryLight,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Currency
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: '幣別',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'TWD', child: Text('TWD')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
              DropdownMenuItem(value: 'JPY', child: Text('JPY')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            ],
            onChanged: (v) => setState(() => _currency = v ?? 'TWD'),
          ),
          const SizedBox(height: 12),

          // Balance
          TextFormField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '初始餘額',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final account = Account()
      ..name = _nameController.text.trim()
      ..type = _type
      ..balance = double.tryParse(_balanceController.text) ?? 0
      ..currency = _currency
      ..assetTerm = defaultAssetTerm(_type)
      ..createdAt = DateTime.now();

    final repo = ref.read(accountRepositoryProvider);
    await repo.add(account);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('帳戶已新增')));
      Navigator.of(context).pop();
    }
  }

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '現金';
      case AccountType.bank:
        return '銀行';
      case AccountType.creditCard:
        return '信用卡';
      case AccountType.eWallet:
        return '電子錢包';
      case AccountType.investment:
        return '投資';
      case AccountType.other:
        return '其他';
    }
  }
}
