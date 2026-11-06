import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/categories/data/repositories/category_repository.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('CategoryRepository', () {
    test('creates and retrieves a category', () async {
      final id = await repository.createCategory(
        name: 'Food',
        description: 'Food products',
      );

      final category = await repository.getCategoryById(id);

      expect(category, isNotNull);
      expect(category!.name, 'Food');
      expect(category.description, 'Food products');
    });

    test('updates a category', () async {
      final id = await repository.createCategory(name: 'Food');

      await repository.updateCategory(
        id: id,
        name: 'Groceries',
        description: 'Grocery products',
      );

      final category = await repository.getCategoryById(id);

      expect(category!.name, 'Groceries');
      expect(category.description, 'Grocery products');
    });

    test('soft deletes a category', () async {
      final id = await repository.createCategory(name: 'Food');

      await repository.deleteCategory(id);

      final category = await repository.getCategoryById(id);
      final categories = await repository.getCategories();

      expect(category, isNull);
      expect(categories, isEmpty);
    });

    test('records create operations in the sync queue', () async {
      await repository.createCategory(name: 'Food');

      final queueEntries = await database
          .select(database.syncQueueEntries)
          .get();

      expect(queueEntries, hasLength(1));
      expect(queueEntries.first.entityTable, 'categories');
      expect(queueEntries.first.operation, 'upsert');
    });
  });
}
