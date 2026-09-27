import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:radarscholar/models/application.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/repositories/application_repository.dart';
import 'package:radarscholar/services/api_service.dart';
import 'package:radarscholar/views/applications/applications_page.dart';

class FakeApplicationRepository extends ApplicationRepository {
  FakeApplicationRepository({this.applications = const [], this.error = false})
    : super(ApiService(dio: Dio()));

  final List<Application> applications;
  final bool error;

  @override
  Future<List<Application>> getApplications() async {
    if (error) throw StateError('internal error must stay hidden');
    return applications;
  }
}

Application makeApplication() {
  final now = DateTime(2027);
  return Application(
    id: 'application-1',
    userId: 'user-1',
    scholarshipId: 'scholarship-1',
    status: ApplicationStatus.inProgress,
    createdAt: now,
    updatedAt: now,
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
    child: const MaterialApp(home: ApplicationsPage()),
  );
}

void main() {
  testWidgets('ApplicationsPage renders empty state', (tester) async {
    await tester.pumpWidget(buildPage(FakeApplicationRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Lamaran'), findsOneWidget);
    expect(find.text('Cari Beasiswa'), findsOneWidget);
  });

  testWidgets('ApplicationsPage renders application data', (tester) async {
    await tester.pumpWidget(
      buildPage(FakeApplicationRepository(applications: [makeApplication()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('TELADAN 2027'), findsOneWidget);
    expect(find.text('0/0 Tugas'), findsOneWidget);
  });

  testWidgets('ApplicationsPage renders safe error state', (tester) async {
    await tester.pumpWidget(buildPage(FakeApplicationRepository(error: true)));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat aplikasi beasiswa.'), findsOneWidget);
    expect(find.textContaining('internal error'), findsNothing);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
