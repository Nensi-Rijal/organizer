import 'package:drift/drift.dart';

import 'categories.dart';
import 'storage_locations.dart';

@DataClassName('InventoryItemRecord')
class InventoryItems extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 150)();

  TextColumn get brand => text().nullable()();

  TextColumn get description => text().nullable()();

  // Category selected by the user.
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  // Where the product is physically stored.
  TextColumn get locationId => text().nullable().references(
    StorageLocations,
    #id,
    onDelete: KeyAction.setNull,
  )();

  // Supports fractional quantities as well.
  RealColumn get quantity => real().withDefault(const Constant(1.0))();

  TextColumn get unit => text().nullable()();

  // unopened, opened, finished
  TextColumn get status => text().withDefault(const Constant('unopened'))();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get expirationDate => dateTime().nullable()();

  DateTimeColumn get openedAt => dateTime().nullable()();

  // Local photo path on the device.
  TextColumn get imageLocalPath => text().nullable()();

  // Storage path for the future Supabase image.
  TextColumn get imageRemotePath => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
