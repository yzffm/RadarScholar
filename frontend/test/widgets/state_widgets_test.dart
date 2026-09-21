import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/widgets/loading_state.dart';
import 'package:radarscholar/widgets/empty_state.dart';
import 'package:radarscholar/widgets/error_state.dart';

void main() {
  group('Reusable State Widgets Tests', () {
    testWidgets('LoadingState renders message and indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Memuat data beasiswa...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat data beasiswa...'), findsOneWidget);
    });

    testWidgets('EmptyState renders title, message and action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Tidak Ada Data',
              message: 'Belum ada beasiswa yang cocok.',
              actionLabel: 'Segarkan',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Tidak Ada Data'), findsOneWidget);
      expect(find.text('Belum ada beasiswa yang cocok.'), findsOneWidget);
      expect(find.text('Segarkan'), findsOneWidget);

      await tester.tap(find.text('Segarkan'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('ErrorState renders error title and retry button', (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Koneksi Gagal',
              message: 'Tidak dapat terhubung ke server.',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Koneksi Gagal'), findsOneWidget);
      expect(find.text('Tidak dapat terhubung ke server.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retryTriggered, isTrue);
    });
  });
}
