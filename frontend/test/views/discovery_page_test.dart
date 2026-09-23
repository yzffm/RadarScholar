import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:radarscholar/controllers/scholarship_controller.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/repositories/scholarship_repository.dart';
import 'package:radarscholar/views/discovery/discovery_page.dart';
import 'package:radarscholar/widgets/scholarship_card.dart';

import 'discovery_page_test.mocks.dart';

@GenerateMocks([ScholarshipRepository])
void main() {
  late MockScholarshipRepository mockRepository;

  setUp(() {
    mockRepository = MockScholarshipRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        scholarshipRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(home: DiscoveryPage()),
    );
  }

  testWidgets('DiscoveryPage shows loading then list of scholarships', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final mockResponse = ScholarshipListResponse(
      items: [
        Scholarship(
          id: '1',
          sourceId: 'src1',
          title: 'Beasiswa Test 1',
          summary: 'Summary 1',
          description: 'Desc 1',
          applicationUrl: 'http://example.com',
          createdAt: now,
          updatedAt: now,
        ),
        Scholarship(
          id: '2',
          sourceId: 'src2',
          title: 'Beasiswa Test 2',
          summary: 'Summary 2',
          description: 'Desc 2',
          applicationUrl: 'http://example.com/2',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      page: 1,
      pageSize: 20,
      total: 2,
      totalPages: 1,
    );

    when(
      mockRepository.getScholarships(
        page: 1,
        pageSize: 20,
        search: null,
        status: null,
      ),
    ).thenAnswer((_) async => mockResponse);

    await tester.pumpWidget(createWidgetUnderTest());

    // Initially loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the Future complete
    await tester.pumpAndSettle();

    // Loading should disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Listview should be present
    expect(find.byType(ListView), findsOneWidget);

    // Cards should be present
    expect(find.byType(ScholarshipCard), findsNWidgets(2));
    expect(find.text('Beasiswa Test 1'), findsOneWidget);
    expect(find.text('Beasiswa Test 2'), findsOneWidget);
  });
}
