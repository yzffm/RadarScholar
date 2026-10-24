import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/views/assistant/assistant_page.dart';

void main() {
  testWidgets('AssistantPage exposes grounded preparation entry point', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AssistantPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ruang Persiapan'), findsOneWidget);
    expect(find.text('Buka Application Tracker'), findsWidgets);
    expect(find.text('Review CV'), findsOneWidget);
    expect(find.text('Data seed'), findsNothing);
  });
}
