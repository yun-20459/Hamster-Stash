import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';

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
    final nameController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新增分類'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '分類名稱',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final type = _tabController.index == 0
                  ? CategoryType.expense
                  : CategoryType.income;

              final cat = Category()
                ..name = name
                ..type = type
                ..isDefault = false
                ..sortOrder = 99
                ..createdAt = DateTime.now();

              final repo = ref.read(categoryRepositoryProvider);
              await repo.add(cat);

              if (ctx.mounted) Navigator.of(ctx).pop();
              // Refresh
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
}
