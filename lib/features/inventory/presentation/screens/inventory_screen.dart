import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:organizer/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:organizer/shared/widgets/app_empty_state.dart';
import 'package:organizer/shared/widgets/app_page_header.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryItemsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Inventory',
                subtitle: 'Everything you own, all in one place.',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: inventoryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text('Unable to load your inventory.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.invalidate(inventoryItemsProvider);
                          },
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Your inventory is empty',
                        description:
                            'Your products will appear here when '
                            'you start adding them.',
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} '
                          '${items.length == 1 ? 'item' : 'items'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (item.brand != null &&
                                          item.brand!.isNotEmpty)
                                        Text(item.brand!),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item.quantity} '
                                                '${item.unit ?? ''}'
                                            .trim(),
                                      ),
                                      Text('Status: ${item.status}'),
                                    ],
                                  ),
                                  trailing: item.isFavorite
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
