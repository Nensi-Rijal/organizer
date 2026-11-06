import 'package:flutter/material.dart';

import 'package:organizer/shared/widgets/app_logo.dart';
import 'package:organizer/shared/widgets/app_page_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                AppLogo(size: 48),
                SizedBox(width: 14),
                Text(
                  'Organizer',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 36),

            const AppPageHeader(
              title: 'Your space.',
              subtitle: 'Everything you own, organized in one place.',
            ),

            const SizedBox(height: 28),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Your inventory starts here',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Keep track of your products, '
                      'categories and storage locations.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'A little more organized, every day.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
