import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/core/scholarship_status.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/widgets/scholarship_card.dart';

Scholarship _buildScholarship({
  DateTime? deadline,
  bool isActive = true,
  String registrationStatus = 'UNKNOWN',
  String dataOrigin = 'CRAWLER_LIVE',
  DateTime? lastVerifiedLiveAt,
}) {
  final base = DateTime.utc(2026, 10, 23, 12);
  return Scholarship(
    id: 'sch-1',
    sourceId: 'src-1',
    title: 'Beasiswa Uji Status',
    summary: 'Ringkasan beasiswa uji.',
    description: 'Deskripsi beasiswa uji.',
    deadline: deadline,
    applicationUrl: 'https://example.com',
    isActive: isActive,
    registrationStatus: registrationStatus,
    dataOrigin: dataOrigin,
    lastVerifiedLiveAt: lastVerifiedLiveAt,
    createdAt: base,
    updatedAt: base,
  );
}

void main() {
  group('registrationStatusOf', () {
    test('returns unknown when deadline is null even if isActive is true', () {
      final s = _buildScholarship(
        deadline: null,
        isActive: true,
        registrationStatus: 'UNKNOWN',
      );
      expect(registrationStatusOf(s), RegistrationStatus.unknown);
    });

    test('returns open when registrationStatus is OPEN', () {
      final s = _buildScholarship(
        deadline: DateTime.utc(2026, 11, 15),
        isActive: true,
        registrationStatus: 'OPEN',
      );
      expect(registrationStatusOf(s), RegistrationStatus.open);
    });

    test('returns closed when registrationStatus is CLOSED', () {
      final s = _buildScholarship(
        deadline: DateTime.utc(2026, 9, 15),
        isActive: true,
        registrationStatus: 'CLOSED',
      );
      expect(registrationStatusOf(s), RegistrationStatus.closed);
    });
  });

  group('verificationInfoOf', () {
    test('formats live verification date and no warning within 14 days', () {
      final s = _buildScholarship(
        dataOrigin: 'CRAWLER_LIVE',
        lastVerifiedLiveAt: DateTime.utc(2026, 10, 20, 12),
      );
      final info = verificationInfoOf(s, now: DateTime.utc(2026, 10, 23, 12));
      expect(
        info.label,
        'Halaman resmi dicek 20 Oct 2026; syarat dan manfaat dikurasi manual',
      );
      expect(info.isLiveChecked, isTrue);
      expect(info.isStale, isFalse);
      expect(info.staleWarning, isNull);
    });

    test('emits staleness warning when lastVerifiedLiveAt > 14 days old', () {
      final s = _buildScholarship(
        dataOrigin: 'CRAWLER_LIVE',
        lastVerifiedLiveAt: DateTime.utc(2026, 10, 1, 12),
      );
      final info = verificationInfoOf(s, now: DateTime.utc(2026, 10, 23, 12));
      expect(
        info.label,
        'Halaman resmi dicek 01 Oct 2026; syarat dan manfaat dikurasi manual',
      );
      expect(info.isLiveChecked, isTrue);
      expect(info.isStale, isTrue);
      expect(
        info.staleWarning,
        'Data mungkin sudah usang: pengecekan terakhir lebih dari 14 hari lalu',
      );
    });
  });

  group('ScholarshipCard widget', () {
    testWidgets('renders neutral badge when deadline is null', (tester) async {
      final s = _buildScholarship(
        deadline: null,
        isActive: true,
        registrationStatus: 'UNKNOWN',
        dataOrigin: 'CRAWLER_LIVE',
        lastVerifiedLiveAt: DateTime.now().toUtc(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScholarshipCard(scholarship: s)),
        ),
      );

      expect(find.text('Status pendaftaran belum diketahui'), findsOneWidget);
      expect(find.text('Aktif'), findsNothing);
      expect(find.text('Pendaftaran Dibuka'), findsNothing);
    });

    testWidgets('renders staleness warning when verification > 14 days ago', (
      tester,
    ) async {
      final s = _buildScholarship(
        deadline: null,
        registrationStatus: 'UNKNOWN',
        dataOrigin: 'CRAWLER_LIVE',
        lastVerifiedLiveAt: DateTime.now().toUtc().subtract(
          const Duration(days: 20),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScholarshipCard(scholarship: s)),
        ),
      );

      expect(
        find.text(
          'Data mungkin sudah usang: pengecekan terakhir lebih dari 14 hari lalu',
        ),
        findsOneWidget,
      );
    });
  });
}
