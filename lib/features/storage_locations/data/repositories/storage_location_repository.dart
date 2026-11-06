import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class StorageLocationRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  StorageLocationRepository(this._database);

  // CREATE
  Future<String> createLocation({
    required String name,
    String? parentId,
    String? description,
  }) async {
    await _validateParent(parentId: parentId);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _database
          .into(_database.storageLocations)
          .insert(
            StorageLocationsCompanion(
              id: Value(id),
              name: Value(name),
              parentId: Value(parentId),
              description: Value(description),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await _addToSyncQueue(recordId: id, operation: 'upsert');
    });

    return id;
  }

  // READ: Retrieve all active locations.
  Future<List<StorageLocationRecord>> getLocations() {
    return (_database.select(_database.storageLocations)
          ..where((location) => location.deletedAt.isNull())
          ..orderBy([(location) => OrderingTerm.asc(location.name)]))
        .get();
  }

  // READ: Watch active locations.
  Stream<List<StorageLocationRecord>> watchLocations() {
    return (_database.select(_database.storageLocations)
          ..where((location) => location.deletedAt.isNull())
          ..orderBy([(location) => OrderingTerm.asc(location.name)]))
        .watch();
  }

  // READ: Retrieve one location.
  Future<StorageLocationRecord?> getLocationById(String id) {
    return (_database.select(_database.storageLocations)..where(
          (location) => location.id.equals(id) & location.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  // READ: Retrieve direct children of a location.
  Future<List<StorageLocationRecord>> getChildLocations(String parentId) {
    return (_database.select(_database.storageLocations)
          ..where(
            (location) =>
                location.parentId.equals(parentId) &
                location.deletedAt.isNull(),
          )
          ..orderBy([(location) => OrderingTerm.asc(location.name)]))
        .get();
  }

  // UPDATE
  Future<void> updateLocation({
    required String id,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final existingLocation = await getLocationById(id);

    if (existingLocation == null) {
      throw StateError('Location does not exist.');
    }

    await _validateParent(parentId: parentId, locationId: id);

    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final updatedCount =
          await (_database.update(_database.storageLocations)..where(
                (location) =>
                    location.id.equals(id) & location.deletedAt.isNull(),
              ))
              .write(
                StorageLocationsCompanion(
                  name: Value(name),
                  parentId: Value(parentId),
                  description: Value(description),
                  updatedAt: Value(now),
                ),
              );

      if (updatedCount > 0) {
        await _addToSyncQueue(recordId: id, operation: 'upsert');
      }
    });
  }

  // SOFT DELETE
  Future<void> deleteLocation(String id) async {
    final existingLocation = await getLocationById(id);

    if (existingLocation == null) {
      throw StateError('Location does not exist.');
    }

    await _validateDeletion(id);
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final deletedCount =
          await (_database.update(_database.storageLocations)..where(
                (location) =>
                    location.id.equals(id) & location.deletedAt.isNull(),
              ))
              .write(
                StorageLocationsCompanion(
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
            entityTable: const Value('storage_locations'),
            recordId: Value(recordId),
            operation: Value(operation),
          ),
        );
  }

  Future<void> _validateParent({
    required String? parentId,
    String? locationId,
  }) async {
    if (parentId == null) return;

    if (parentId == locationId) {
      throw StateError('A location cannot be its own parent.');
    }

    final locations = await getLocations();

    final parentExists = locations.any((location) => location.id == parentId);

    if (!parentExists) {
      throw StateError('Selected parent location does not exist.');
    }

    String? currentParentId = parentId;

    while (currentParentId != null) {
      if (currentParentId == locationId) {
        throw StateError(
          'This parent would create a circular location hierarchy.',
        );
      }

      final parent = locations.where(
        (location) => location.id == currentParentId,
      );

      if (parent.isEmpty) break;

      currentParentId = parent.first.parentId;
    }
  }

  Future<void> _validateDeletion(String id) async {
    final children = await getChildLocations(id);

    if (children.isNotEmpty) {
      throw StateError(
        'Move or delete child locations before deleting this location.',
      );
    }

    final inventoryItems =
        await (_database.select(_database.inventoryItems)..where(
              (item) => item.locationId.equals(id) & item.deletedAt.isNull(),
            ))
            .get();

    if (inventoryItems.isNotEmpty) {
      throw StateError(
        'Move inventory items to another location before deleting this location.',
      );
    }
  }
}

final storageLocationRepositoryProvider = Provider<StorageLocationRepository>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return StorageLocationRepository(database);
});
