import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radarscholar/views/auth/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('Renders all form fields and special Google Login button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang Kembali'), findsOneWidget);
      expect(find.text('Masuk dengan Google'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Ingat saya'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Daftar Sekarang'), findsOneWidget);
    });

    testWidgets('Shows validation error when submitting empty fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.text('Masuk ke Akun');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
    });
  });
}
