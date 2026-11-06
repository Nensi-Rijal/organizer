import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:organizer/app/organizer_app.dart';

void main() {
  testWidgets('Organizer app loads successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OrganizerApp()));

    await tester.pumpAndSettle();

    expect(find.text('Your space.'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
