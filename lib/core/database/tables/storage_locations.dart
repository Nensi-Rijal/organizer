import 'package:drift/drift.dart';

@DataClassName('StorageLocationRecord')
class StorageLocations extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get parentId => text().nullable().references(
    StorageLocations,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
