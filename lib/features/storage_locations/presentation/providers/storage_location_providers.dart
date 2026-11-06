import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:organizer/core/database/app_database.dart';
import 'package:organizer/features/storage_locations/data/repositories/storage_location_repository.dart';

final storageLocationsProvider =
    StreamProvider.autoDispose<List<StorageLocationRecord>>((ref) {
      final repository = ref.watch(storageLocationRepositoryProvider);

      return repository.watchLocations();
    });
