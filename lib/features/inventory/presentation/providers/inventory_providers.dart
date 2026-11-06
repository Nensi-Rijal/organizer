import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/categories/data/repositories/category_repository.dart';
import 'package:organizer/features/storage_locations/data/repositories/storage_location_repository.dart';
import 'package:organizer/features/inventory/data/repositories/inventory_repository.dart';

final inventoryItemsProvider =
    StreamProvider.autoDispose<List<InventoryItemRecord>>((ref) {
      final repository = ref.watch(inventoryRepositoryProvider);
      return repository.watchItems();
    });

final inventoryFormCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryRecord>>((ref) {
      final repository = ref.watch(categoryRepositoryProvider);
      return repository.watchCategories();
    });

final inventoryFormLocationsProvider =
    StreamProvider.autoDispose<List<StorageLocationRecord>>((ref) {
      final repository = ref.watch(storageLocationRepositoryProvider);
      return repository.watchLocations();
    });
