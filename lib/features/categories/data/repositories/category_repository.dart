import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class CategoryRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  CategoryRepository(this._database);

  // CREATE
  Future<String> createCategory({
    required String name,
    String? parentId,
    String? description,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _database
          .into(_database.categories)
          .insert(
            CategoriesCompanion(
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

  // READ: Retrieve all active categories.
  Future<List<CategoryRecord>> getCategories() {
    return (_database.select(_database.categories)
          ..where((category) => category.deletedAt.isNull())
          ..orderBy([(category) => OrderingTerm.asc(category.name)]))
        .get();
  }

  // READ: Watch active categories.
  Stream<List<CategoryRecord>> watchCategories() {
    return (_database.select(_database.categories)
          ..where((category) => category.deletedAt.isNull())
          ..orderBy([(category) => OrderingTerm.asc(category.name)]))
        .watch();
  }

  // READ: Retrieve one category.
  Future<CategoryRecord?> getCategoryById(String id) {
    return (_database.select(_database.categories)..where(
          (category) => category.id.equals(id) & category.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  // UPDATE
  Future<void> updateCategory({
    required String id,
    required String name,
    String? parentId,
    String? description,
  }) async {
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final updatedCount =
          await (_database.update(_database.categories)..where(
                (category) =>
                    category.id.equals(id) & category.deletedAt.isNull(),
              ))
              .write(
                CategoriesCompanion(
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
  Future<void> deleteCategory(String id) async {
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final deletedCount =
          await (_database.update(_database.categories)..where(
                (category) =>
                    category.id.equals(id) & category.deletedAt.isNull(),
              ))
              .write(
                CategoriesCompanion(
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
            entityTable: const Value('categories'),
            recordId: Value(recordId),
            operation: Value(operation),
          ),
        );
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return CategoryRepository(database);
});
