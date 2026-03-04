// Basic Flutter widget test for Card Organizer app.

import 'package:flutter_test/flutter_test.dart';

import 'package:in_class_8/main.dart';

void main() {
  testWidgets('App starts and shows Card Organizer title', (WidgetTester tester) async {
    await tester.pumpWidget(const CardOrganizerApp());
    expect(find.text('Card Organizer'), findsOneWidget);
  });
}
