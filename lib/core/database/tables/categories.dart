import 'package:drift/drift.dart';

@DataClassName('CategoryRecord')
class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  // Null means this is a top-level category.
  // Otherwise, it references another category.
  TextColumn get parentId => text().nullable().references(
    Categories,
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
