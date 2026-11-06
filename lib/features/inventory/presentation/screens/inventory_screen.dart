import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_page_header.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPageHeader(
              title: 'Inventory',
              subtitle: 'Everything you own, all in one place.',
            ),

            const SizedBox(height: 24),

            Expanded(
              child: AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Your inventory is empty',
                description:
                    'Your products will appear here when '
                    'you start adding them.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
