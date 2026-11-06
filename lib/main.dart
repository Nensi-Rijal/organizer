import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/organizer_app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the local database.
  final database = AppDatabase();

  // Run a small query to verify the database opens.
  await database.customSelect('SELECT 1').get();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const OrganizerApp(),
    ),
  );
}
