import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/inventory/data/repositories/inventory_repository.dart';

void main() {
  late AppDatabase database;
  late InventoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = InventoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('InventoryRepository', () {
    test('creates and retrieves an inventory item', () async {
      final id = await repository.createItem(
        name: 'Milk',
        brand: 'Organic Valley',
        quantity: 2,
        unit: 'bottles',
      );

      final item = await repository.getItemById(id);

      expect(item, isNotNull);
      expect(item!.name, 'Milk');
      expect(item.brand, 'Organic Valley');
      expect(item.quantity, 2);
      expect(item.unit, 'bottles');
    });

    test('updates an inventory item', () async {
      final id = await repository.createItem(name: 'Milk', quantity: 1);

      await repository.updateItem(
        id: id,
        name: 'Whole Milk',
        quantity: 2,
        unit: 'bottles',
      );

      final item = await repository.getItemById(id);

      expect(item!.name, 'Whole Milk');
      expect(item.quantity, 2);
      expect(item.unit, 'bottles');
    });

    test('filters items by category', () async {
      const categoryId = 'food-category';

      await database
          .into(database.categories)
          .insert(CategoriesCompanion.insert(id: categoryId, name: 'Food'));

      await repository.createItem(name: 'Milk', categoryId: categoryId);

      await repository.createItem(name: 'Shampoo');

      final items = await repository.getItemsByCategory(categoryId);

      expect(items, hasLength(1));
      expect(items.first.name, 'Milk');
    });

    test('filters items by storage location', () async {
      const locationId = 'kitchen-location';

      await database
          .into(database.storageLocations)
          .insert(
            StorageLocationsCompanion.insert(id: locationId, name: 'Kitchen'),
          );

      await repository.createItem(name: 'Milk', locationId: locationId);

      await repository.createItem(name: 'Shampoo');

      final items = await repository.getItemsByLocation(locationId);

      expect(items, hasLength(1));
      expect(items.first.name, 'Milk');
    });

    test('retrieves favorite items', () async {
      await repository.createItem(name: 'Milk', isFavorite: true);

      await repository.createItem(name: 'Shampoo');

      final favorites = await repository.getFavoriteItems();

      expect(favorites, hasLength(1));
      expect(favorites.first.name, 'Milk');
    });

    test('toggles favorite status', () async {
      final id = await repository.createItem(name: 'Milk');

      await repository.toggleFavorite(id);

      var item = await repository.getItemById(id);
      expect(item!.isFavorite, isTrue);

      await repository.toggleFavorite(id);

      item = await repository.getItemById(id);
      expect(item!.isFavorite, isFalse);
    });

    test('soft deletes an inventory item', () async {
      final id = await repository.createItem(name: 'Milk');

      await repository.deleteItem(id);

      final item = await repository.getItemById(id);
      final items = await repository.getItems();

      expect(item, isNull);
      expect(items, isEmpty);
    });

    test('records create operations in the sync queue', () async {
      await repository.createItem(name: 'Milk');

      final entries = await database.select(database.syncQueueEntries).get();

      expect(entries, hasLength(1));
      expect(entries.first.entityTable, 'inventory_items');
      expect(entries.first.operation, 'upsert');
    });

    test('rejects an empty product name', () async {
      expect(() => repository.createItem(name: '   '), throwsArgumentError);
    });

    test('rejects a negative quantity', () async {
      expect(
        () => repository.createItem(name: 'Milk', quantity: -1),
        throwsArgumentError,
      );
    });
  });
}
