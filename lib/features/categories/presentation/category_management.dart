import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';

const _colorPresets = [
  '#FF6B35',
  '#E74C3C',
  '#9B59B6',
  '#3498DB',
  '#1ABC9C',
  '#2ECC71',
  '#F39C12',
  '#E67E22',
  '#95A5A6',
  '#34495E',
  '#FF85A2',
  '#7C4DFF',
];

class CategoryManagement extends ConsumerStatefulWidget {
  const CategoryManagement({super.key});

  @override
  ConsumerState<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends ConsumerState<CategoryManagement>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分類管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '支出'),
              Tab(text: '收入'),
            ],
            labelColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _CategoryList(type: CategoryType.expense),
                _CategoryList(type: CategoryType.income),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    var selectedColor = _colorPresets.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新增分類'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '分類名稱',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emojiCtrl,
                  decoration: const InputDecoration(
                    labelText: '圖示 Emoji',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPresets.map((hex) {
                    final color = Color(
                      int.parse(hex.substring(1), radix: 16) + 0xFF000000,
                    );
                    final isSelected = hex == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(width: 3) : null,
                        ),
                      ),
                    );
                  }).toList(),
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
                if (name.isEmpty) return;

                final type = _tabController.index == 0
                    ? CategoryType.expense
                    : CategoryType.income;

                final cat = Category()
                  ..name = name
                  ..type = type
                  ..iconEmoji = emojiCtrl.text.trim().isEmpty
                      ? null
                      : emojiCtrl.text.trim()
                  ..colorHex = selectedColor
                  ..isDefault = false
                  ..sortOrder = 99
                  ..createdAt = DateTime.now();

                final repo = ref.read(categoryRepositoryProvider);
                await repo.add(cat);

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (type == CategoryType.expense) {
                  ref.invalidate(expenseParentsProvider);
                } else {
                  ref.invalidate(incomeParentsProvider);
                }
              },
              child: const Text('新增'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = type == CategoryType.expense
        ? ref.watch(expenseParentsProvider)
        : ref.watch(incomeParentsProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('沒有分類'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ListTile(
              onTap: cat.isDefault
                  ? null
                  : () => _showEditDialog(context, ref, cat, type),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  cat.iconEmoji ?? '\u{1F4C1}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(cat.name),
              trailing: cat.isDefault
                  ? const Text(
                      '預設',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () async {
                        final repo = ref.read(categoryRepositoryProvider);
                        await repo.deleteWithChildren(cat.id);
                        if (type == CategoryType.expense) {
                          ref.invalidate(expenseParentsProvider);
                        } else {
                          ref.invalidate(incomeParentsProvider);
                        }
                      },
                    ),
            );
          },
        );
      },
    );
  }

  static void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Category cat,
    CategoryType type,
  ) {
    final nameCtrl = TextEditingController(text: cat.name);
    final emojiCtrl = TextEditingController(text: cat.iconEmoji ?? '');
    var selectedColor = cat.colorHex ?? '#FF6B35';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('編輯分類'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '分類名稱',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emojiCtrl,
                  decoration: const InputDecoration(
                    labelText: '圖示 Emoji',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPresets.map((hex) {
                    final color = Color(
                      int.parse(hex.substring(1), radix: 16) + 0xFF000000,
                    );
                    final isSelected = hex == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(width: 3) : null,
                        ),
                      ),
                    );
                  }).toList(),
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
                if (name.isEmpty) return;

                cat
                  ..name = name
                  ..iconEmoji = emojiCtrl.text.trim().isEmpty
                      ? null
                      : emojiCtrl.text.trim()
                  ..colorHex = selectedColor;

                final repo = ref.read(categoryRepositoryProvider);
                await repo.update(cat);

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (type == CategoryType.expense) {
                  ref.invalidate(expenseParentsProvider);
                } else {
                  ref.invalidate(incomeParentsProvider);
                }
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }
}
