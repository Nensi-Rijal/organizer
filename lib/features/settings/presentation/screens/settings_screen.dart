import 'package:flutter/material.dart';

import 'package:organizer/shared/widgets/app_page_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPageHeader(
              title: 'Settings',
              subtitle: 'Manage your Organizer experience.',
            ),

            const SizedBox(height: 28),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Account'),
                subtitle: const Text('Account settings will appear here.'),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Appearance'),
                subtitle: const Text('Customize your app experience.'),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Organizer'),
                subtitle: const Text('Your personal organization space.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
