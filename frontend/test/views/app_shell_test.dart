import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radarscholar/views/shell/app_shell.dart';

void main() {
  group('AppShell Responsive Tests', () {
    testWidgets('Renders bottom NavigationBar on mobile viewport (< 600px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(child: Text('Mobile Shell Child Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Mobile Shell Child Content'), findsOneWidget);
    });

    testWidgets('Renders NavigationRail on tablet viewport (600px - 1024px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(child: Text('Tablet Shell Child Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Tablet Shell Child Content'), findsOneWidget);
    });

    testWidgets('Renders persistent Sidebar on desktop viewport (>= 1024px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShell(child: Text('Desktop Shell Child Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Eksplorasi'), findsOneWidget);
      expect(find.text('Tersimpan'), findsOneWidget);
      expect(find.text('Pelacakan'), findsOneWidget);
      expect(find.text('Desktop Shell Child Content'), findsOneWidget);
    });
  });
}
