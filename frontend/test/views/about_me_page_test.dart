import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radarscholar/views/about/about_me_page.dart';

void main() {
  group('AboutMePage Widget Tests', () {
    testWidgets(
      'AboutMePage renders Creator Profile, 3D Hologram ID Badge, and 3D Architecture Orbit with 3D Logo Core',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AboutMePage())),
        );
        await tester.pumpAndSettle();

        expect(find.text(CreatorProfileConfig.fullName), findsWidgets);
        expect(find.text(CreatorProfileConfig.handle), findsWidgets);
        expect(find.text('3D HOLOGRAM ID'), findsOneWidget);
        expect(find.text('Balik Kartu'), findsOneWidget);

        // Verify 3D Architecture Orbit shows central 3D RadarScholar Core and floating 3D module badges
        expect(find.text('RADARSCHOLAR CORE'), findsOneWidget);
        expect(find.text('Flutter 3D UI'), findsOneWidget);
        expect(find.text('Riverpod MVC'), findsOneWidget);
        expect(find.text('FastAPI REST'), findsOneWidget);

        // Flip the 3D Hologram ID Card to the back side
        await tester.tap(find.text('Balik Kartu'));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('badge_back')), findsOneWidget);
        expect(find.text('Lihat Sisi Depan'), findsOneWidget);
      },
    );
  });
}
