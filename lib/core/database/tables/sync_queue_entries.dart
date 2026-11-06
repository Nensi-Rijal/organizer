import 'package:drift/drift.dart';

@DataClassName('SyncQueueEntryRecord')
class SyncQueueEntries extends Table {
  TextColumn get id => text()();

  // Example: inventory_items, categories, storage_locations
  TextColumn get entityTable => text().named('table_name')();

  // ID of the record that needs synchronization.
  TextColumn get recordId => text()();

  // upsert or delete
  TextColumn get operation => text()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
