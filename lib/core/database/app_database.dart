import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/categories.dart';
import 'tables/storage_locations.dart';
import 'tables/inventory_items.dart';
import 'tables/sync_queue_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, StorageLocations, InventoryItems, SyncQueueEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'organizer_database'));

  @override
  int get schemaVersion => 1;
}
