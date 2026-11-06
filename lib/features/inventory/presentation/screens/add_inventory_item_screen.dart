import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:organizer/features/inventory/data/repositories/inventory_repository.dart';
import 'package:organizer/features/inventory/presentation/providers/inventory_providers.dart';

import 'package:organizer/core/database/app_database.dart';

class AddInventoryItemScreen extends ConsumerStatefulWidget {
  const AddInventoryItemScreen({super.key});

  @override
  ConsumerState<AddInventoryItemScreen> createState() =>
      _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState
    extends ConsumerState<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  String? _categoryId;
  String? _locationId;
  String _status = 'unopened';
  DateTime? _expirationDate;
  bool _isFavorite = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _expirationDate = selectedDate;
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(inventoryRepositoryProvider);

      await repository.createItem(
        name: _nameController.text,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _categoryId,
        locationId: _locationId,
        quantity: quantity,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        status: _status,
        isFavorite: _isFavorite,
        expirationDate: _expirationDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory item added successfully.')),
      );

      context.pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save item: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(inventoryFormCategoriesProvider);
    final locationsAsync = ref.watch(inventoryFormLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Inventory Item')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildLoadError(
          'Unable to load categories.',
          () => ref.invalidate(inventoryFormCategoriesProvider),
        ),
        data: (categories) => locationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildLoadError(
            'Unable to load storage locations.',
            () => ref.invalidate(inventoryFormLocationsProvider),
          ),
          data: (locations) => _buildForm(categories, locations),
        ),
      ),
    );
  }

  Widget _buildLoadError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    List<CategoryRecord> categories,
    List<StorageLocationRecord> locations,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Product details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Product name *',
              hintText: 'e.g. Olive Oil',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a product name.';
              }
              if (value.trim().length > 150) {
                return 'Name cannot exceed 150 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _brandController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Brand',
              hintText: 'e.g. California Olive Ranch',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Add product details...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          Text('Organization', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          DropdownButtonFormField<String?>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No category'),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _categoryId = value;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String?>(
            initialValue: _locationId,
            decoration: const InputDecoration(
              labelText: 'Storage location',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No location'),
              ),
              ...locations.map(
                (location) => DropdownMenuItem<String?>(
                  value: location.id,
                  child: Text(location.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _locationId = value;
              });
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Quantity and status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final quantity = double.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity < 0) {
                      return 'Enter a valid quantity.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'e.g. bottles',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Product status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'unopened', child: Text('Unopened')),
              DropdownMenuItem(value: 'opened', child: Text('Opened')),
              DropdownMenuItem(value: 'finished', child: Text('Finished')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Expiration date'),
            subtitle: Text(
              _expirationDate == null
                  ? 'No expiration date selected'
                  : _formatDate(_expirationDate!),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_expirationDate != null)
                  IconButton(
                    tooltip: 'Clear date',
                    onPressed: () {
                      setState(() {
                        _expirationDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                IconButton(
                  tooltip: 'Choose date',
                  onPressed: _selectExpirationDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favorite'),
            subtitle: const Text('Mark this item as a favorite.'),
            value: _isFavorite,
            onChanged: (value) {
              setState(() {
                _isFavorite = value;
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Anything else you want to remember?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: _isSaving ? null : _saveItem,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving...' : 'Save item'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
