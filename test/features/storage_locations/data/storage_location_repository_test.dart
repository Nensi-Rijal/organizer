import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/storage_locations/data/repositories/storage_location_repository.dart';

void main() {
  late AppDatabase database;
  late StorageLocationRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = StorageLocationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('StorageLocationRepository', () {
    test('creates and retrieves a location', () async {
      final id = await repository.createLocation(
        name: 'Kitchen',
        description: 'Main kitchen',
      );

      final location = await repository.getLocationById(id);

      expect(location, isNotNull);
      expect(location!.name, 'Kitchen');
      expect(location.description, 'Main kitchen');
    });

    test('creates a nested location', () async {
      final parentId = await repository.createLocation(name: 'Kitchen');

      final childId = await repository.createLocation(
        name: 'Refrigerator',
        parentId: parentId,
      );

      final children = await repository.getChildLocations(parentId);

      expect(children, hasLength(1));
      expect(children.first.id, childId);
      expect(children.first.parentId, parentId);
    });

    test('updates a location', () async {
      final id = await repository.createLocation(name: 'Kitchen');

      await repository.updateLocation(
        id: id,
        name: 'Main Kitchen',
        description: 'Updated description',
      );

      final location = await repository.getLocationById(id);

      expect(location!.name, 'Main Kitchen');
      expect(location.description, 'Updated description');
    });

    test('soft deletes a location', () async {
      final id = await repository.createLocation(name: 'Kitchen');

      await repository.deleteLocation(id);

      final location = await repository.getLocationById(id);
      final locations = await repository.getLocations();

      expect(location, isNull);
      expect(locations, isEmpty);
    });

    test('records operations in the sync queue', () async {
      await repository.createLocation(name: 'Kitchen');

      final entries = await database.select(database.syncQueueEntries).get();

      expect(entries, hasLength(1));
      expect(entries.first.entityTable, 'storage_locations');
      expect(entries.first.operation, 'upsert');
    });
  });
}
