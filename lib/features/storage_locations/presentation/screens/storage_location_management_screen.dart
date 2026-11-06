import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/storage_locations/data/repositories/storage_location_repository.dart';
import 'package:organizer/features/storage_locations/presentation/providers/storage_location_providers.dart';

class StorageLocationManagementScreen extends ConsumerWidget {
  const StorageLocationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(storageLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Storage Locations')),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load locations: $error'),
          ),
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No storage locations yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('Add a location to organize your products.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final location = locations[index];

              return _LocationTile(
                location: location,
                onEdit: () =>
                    _openDialog(context, ref, locations, location: location),
                onDelete: () => _confirmDelete(context, ref, location),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(
          context,
          ref,
          locationsAsync.when(
            data: (locations) => locations,
            loading: () => <StorageLocationRecord>[],
            error: (_, _) => <StorageLocationRecord>[],
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Location'),
      ),
    );
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref,
    List<StorageLocationRecord> locations, {
    StorageLocationRecord? location,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _StorageLocationDialog(locations: locations, location: location),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StorageLocationRecord location,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(storageLocationRepositoryProvider)
          .deleteLocation(location.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${location.name} deleted successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete location: $error')),
      );
    }
  }
}

class _LocationTile extends StatelessWidget {
  final StorageLocationRecord location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationTile({
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.folder_outlined)),
      title: Text(location.name),
      subtitle: location.description?.isNotEmpty == true
          ? Text(location.description!)
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

class _StorageLocationDialog extends ConsumerStatefulWidget {
  final List<StorageLocationRecord> locations;
  final StorageLocationRecord? location;

  const _StorageLocationDialog({required this.locations, this.location});

  @override
  ConsumerState<_StorageLocationDialog> createState() =>
      _StorageLocationDialogState();
}

class _StorageLocationDialogState
    extends ConsumerState<_StorageLocationDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String? _parentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.location?.name ?? '');

    _descriptionController = TextEditingController(
      text: widget.location?.description ?? '',
    );

    _parentId = widget.location?.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location name is required.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(storageLocationRepositoryProvider);

      final description = _descriptionController.text.trim();

      if (widget.location == null) {
        await repository.createLocation(
          name: name,
          parentId: _parentId,
          description: description.isEmpty ? null : description,
        );
      } else {
        await repository.updateLocation(
          id: widget.location!.id,
          name: name,
          parentId: _parentId,
          description: description.isEmpty ? null : description,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save location: $error')),
      );

      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableParents = widget.locations
        .where((item) => item.id != widget.location?.id)
        .toList();

    return AlertDialog(
      title: Text(widget.location == null ? 'Add Location' : 'Edit Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Location name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _parentId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Parent location',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No parent'),
                ),
                ...availableParents.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(item.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _parentId = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
