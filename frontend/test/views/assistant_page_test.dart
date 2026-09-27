import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/views/assistant/assistant_page.dart';

void main() {
  testWidgets('AssistantPage exposes grounded preparation entry point', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AssistantPage()));

    expect(find.text('Ruang Persiapan'), findsOneWidget);
    expect(find.text('Buka Application Tracker'), findsOneWidget);
    expect(find.text('Review CV'), findsOneWidget);
    expect(find.text('Data seed'), findsNothing);
  });
}
