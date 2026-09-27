import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:radarscholar/models/application.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/repositories/application_repository.dart';
import 'package:radarscholar/services/api_service.dart';
import 'package:radarscholar/views/saved/saved_page.dart';

class FakeApplicationRepository extends ApplicationRepository {
  FakeApplicationRepository({this.saved = const [], this.error = false})
    : super(ApiService(dio: Dio()));

  final List<SavedScholarship> saved;
  final bool error;

  @override
  Future<List<SavedScholarship>> getSavedScholarships() async {
    if (error) throw StateError('database details must stay hidden');
    return saved;
  }
}

SavedScholarship makeSaved() {
  final now = DateTime(2027);
  return SavedScholarship(
    id: 'saved-1',
    userId: 'user-1',
    scholarshipId: 'scholarship-1',
    savedAt: now,
    scholarship: Scholarship(
      id: 'scholarship-1',
      sourceId: 'source-1',
      title: 'TELADAN 2027',
      summary: 'Program kepemimpinan mahasiswa.',
      description: 'Description',
      applicationUrl: 'https://example.com',
      createdAt: now,
      updatedAt: now,
      dataOrigin: 'CRAWLER_LIVE',
    ),
  );
}

Widget buildPage(FakeApplicationRepository repository) {
  return ProviderScope(
    overrides: [applicationRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: SavedPage()),
  );
}

void main() {
  testWidgets('SavedPage renders an honest empty state', (tester) async {
    await tester.pumpWidget(buildPage(FakeApplicationRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Beasiswa Tersimpan'), findsOneWidget);
    expect(find.text('Cari Beasiswa'), findsOneWidget);
    expect(find.text('database details must stay hidden'), findsNothing);
  });

  testWidgets('SavedPage renders saved scholarship cards', (tester) async {
    await tester.pumpWidget(
      buildPage(FakeApplicationRepository(saved: [makeSaved()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('TELADAN 2027'), findsOneWidget);
    expect(find.text('Sumber resmi terverifikasi live'), findsOneWidget);
  });

  testWidgets('SavedPage sanitizes repository errors', (tester) async {
    await tester.pumpWidget(buildPage(FakeApplicationRepository(error: true)));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Daftar tersimpan belum dapat dimuat. Periksa koneksi dan coba lagi.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('database details'), findsNothing);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
