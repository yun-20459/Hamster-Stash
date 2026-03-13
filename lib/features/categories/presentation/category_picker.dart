import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hamster_stash/core/database/collections/category.dart';
import 'package:hamster_stash/core/database/enums.dart';
import 'package:hamster_stash/core/theme/app_colors.dart';
import 'package:hamster_stash/features/categories/presentation/category_providers.dart';

class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({
    required this.type,
    required this.onSelected,
    super.key,
  });

  final CategoryType type;
  final void Function(Category category) onSelected;

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  int? _expandedParentId;

  @override
  Widget build(BuildContext context) {
    final parentsAsync = widget.type == CategoryType.expense
        ? ref.watch(expenseParentsProvider)
        : ref.watch(incomeParentsProvider);

    return parentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (parents) {
        if (_expandedParentId != null) {
          return _ChildGrid(
            parentId: _expandedParentId!,
            onSelected: widget.onSelected,
            onBack: () => setState(() => _expandedParentId = null),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final category = parents[index];
            return _CategoryTile(
              category: category,
              onTap: () => _onParentTap(category),
            );
          },
        );
      },
    );
  }

  void _onParentTap(Category parent) {
    // Check if parent has children; if not, select directly
    ref.read(childrenProvider(parent.id).future).then((children) {
      if (children.isEmpty) {
        widget.onSelected(parent);
      } else {
        setState(() => _expandedParentId = parent.id);
      }
    });
  }
}

class _ChildGrid extends ConsumerWidget {
  const _ChildGrid({
    required this.parentId,
    required this.onSelected,
    required this.onBack,
  });

  final int parentId;
  final void Function(Category) onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider(parentId));

    return childrenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (children) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('返回'),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return _CategoryTile(
                  category: child,
                  onTap: () => onSelected(child),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Text(
              category.iconEmoji ?? '\u{1F4C1}',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
