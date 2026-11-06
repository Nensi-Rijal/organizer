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
}

final storageLocationRepositoryProvider = Provider<StorageLocationRepository>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return StorageLocationRepository(database);
});
