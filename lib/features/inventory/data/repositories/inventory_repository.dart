import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class InventoryRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  InventoryRepository(this._database);

  // CREATE
  Future<String> createItem({
    required String name,
    String? brand,
    String? description,
    String? categoryId,
    String? locationId,
    double quantity = 1.0,
    String? unit,
    String status = 'unopened',
    bool isFavorite = false,
    DateTime? expirationDate,
    DateTime? openedAt,
    String? imageLocalPath,
    String? imageRemotePath,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Product name cannot be empty.');
    }

    if (quantity < 0) {
      throw ArgumentError('Quantity cannot be negative.');
    }

    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _database
          .into(_database.inventoryItems)
          .insert(
            InventoryItemsCompanion(
              id: Value(id),
              name: Value(name.trim()),
              brand: Value(brand),
              description: Value(description),
              categoryId: Value(categoryId),
              locationId: Value(locationId),
              quantity: Value(quantity),
              unit: Value(unit),
              status: Value(status),
              isFavorite: Value(isFavorite),
              expirationDate: Value(expirationDate),
              openedAt: Value(openedAt),
              imageLocalPath: Value(imageLocalPath),
              imageRemotePath: Value(imageRemotePath),
              notes: Value(notes),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await _addToSyncQueue(recordId: id, operation: 'upsert');
    });

    return id;
  }

  // READ: Retrieve all active inventory items.
  Future<List<InventoryItemRecord>> getItems() {
    return (_database.select(_database.inventoryItems)
          ..where((item) => item.deletedAt.isNull())
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .get();
  }

  // READ: Watch all active inventory items.
  Stream<List<InventoryItemRecord>> watchItems() {
    return (_database.select(_database.inventoryItems)
          ..where((item) => item.deletedAt.isNull())
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .watch();
  }

  // READ: Retrieve one item by ID.
  Future<InventoryItemRecord?> getItemById(String id) {
    return (_database.select(_database.inventoryItems)
          ..where((item) => item.id.equals(id) & item.deletedAt.isNull()))
        .getSingleOrNull();
  }

  // READ: Retrieve items belonging to a category.
  Future<List<InventoryItemRecord>> getItemsByCategory(String categoryId) {
    return (_database.select(_database.inventoryItems)
          ..where(
            (item) =>
                item.categoryId.equals(categoryId) & item.deletedAt.isNull(),
          )
          ..orderBy([(item) => OrderingTerm.asc(item.name)]))
        .get();
  }

  // READ: Retrieve items stored at a location.
  Future<List<InventoryItemRecord>> getItemsByLocation(String locationId) {
    return (_database.select(_database.inventoryItems)
          ..where(
            (item) =>
                item.locationId.equals(locationId) & item.deletedAt.isNull(),
          )
          ..orderBy([(item) => OrderingTerm.asc(item.name)]))
        .get();
  }

  // READ: Retrieve favorite items.
  Future<List<InventoryItemRecord>> getFavoriteItems() {
    return (_database.select(_database.inventoryItems)
          ..where(
            (item) => item.isFavorite.equals(true) & item.deletedAt.isNull(),
          )
          ..orderBy([(item) => OrderingTerm.asc(item.name)]))
        .get();
  }

  // UPDATE
  Future<void> updateItem({
    required String id,
    required String name,
    String? brand,
    String? description,
    String? categoryId,
    String? locationId,
    double quantity = 1.0,
    String? unit,
    String status = 'unopened',
    bool isFavorite = false,
    DateTime? expirationDate,
    DateTime? openedAt,
    String? imageLocalPath,
    String? imageRemotePath,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Product name cannot be empty.');
    }

    if (quantity < 0) {
      throw ArgumentError('Quantity cannot be negative.');
    }

    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final updatedCount =
          await (_database.update(_database.inventoryItems)
                ..where((item) => item.id.equals(id) & item.deletedAt.isNull()))
              .write(
                InventoryItemsCompanion(
                  name: Value(name.trim()),
                  brand: Value(brand),
                  description: Value(description),
                  categoryId: Value(categoryId),
                  locationId: Value(locationId),
                  quantity: Value(quantity),
                  unit: Value(unit),
                  status: Value(status),
                  isFavorite: Value(isFavorite),
                  expirationDate: Value(expirationDate),
                  openedAt: Value(openedAt),
                  imageLocalPath: Value(imageLocalPath),
                  imageRemotePath: Value(imageRemotePath),
                  notes: Value(notes),
                  updatedAt: Value(now),
                ),
              );

      if (updatedCount > 0) {
        await _addToSyncQueue(recordId: id, operation: 'upsert');
      }
    });
  }

  // UPDATE: Toggle favorite status.
  Future<void> toggleFavorite(String id) async {
    await _database.transaction(() async {
      final item = await getItemById(id);

      if (item == null) return;

      await (_database.update(
        _database.inventoryItems,
      )..where((row) => row.id.equals(id))).write(
        InventoryItemsCompanion(
          isFavorite: Value(!item.isFavorite),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      await _addToSyncQueue(recordId: id, operation: 'upsert');
    });
  }

  // SOFT DELETE
  Future<void> deleteItem(String id) async {
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final deletedCount =
          await (_database.update(_database.inventoryItems)
                ..where((item) => item.id.equals(id) & item.deletedAt.isNull()))
              .write(
                InventoryItemsCompanion(
                  deletedAt: Value(now),
                  updatedAt: Value(now),
                ),
              );

      if (deletedCount > 0) {
        await _addToSyncQueue(recordId: id, operation: 'delete');
      }
    });
  }

  // Add a pending operation to the synchronization queue.
  Future<void> _addToSyncQueue({
    required String recordId,
    required String operation,
  }) {
    return _database
        .into(_database.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion(
            id: Value(_uuid.v4()),
            entityTable: const Value('inventory_items'),
            recordId: Value(recordId),
            operation: Value(operation),
          ),
        );
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return InventoryRepository(database);
});
