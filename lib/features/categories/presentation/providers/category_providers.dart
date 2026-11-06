import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/categories/data/repositories/category_repository.dart';

final categoriesProvider = StreamProvider.autoDispose<List<CategoryRecord>>((
  ref,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchCategories();
});
