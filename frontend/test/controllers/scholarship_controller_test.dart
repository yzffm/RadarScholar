import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/controllers/scholarship_controller.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/repositories/scholarship_repository.dart';

class FakeScholarshipRepository implements ScholarshipRepository {
  int calls = 0;
  late Future<ScholarshipListResponse> Function(int page) response;

  @override
  Future<ScholarshipListResponse> getScholarships({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) {
    calls++;
    return response(page);
  }

  @override
  Future<Scholarship> getScholarshipDetail(String id) {
    throw UnimplementedError();
  }
}

void main() {
  test('does not issue concurrent pagination requests', () async {
    final repository = FakeScholarshipRepository();
    final firstResponse = ScholarshipListResponse(
      items: [
        Scholarship(
          id: '1',
          sourceId: 'source',
          title: 'Test',
          summary: 'Summary',
          description: 'Description',
          applicationUrl: 'https://example.com',
          createdAt: DateTime(2027),
          updatedAt: DateTime(2027),
        ),
      ],
      page: 1,
      pageSize: 20,
      total: 1,
      totalPages: 1,
    );
    final pending = Completer<ScholarshipListResponse>();
    repository.response = (_) => pending.future;
    final controller = ScholarshipController(repository);

    final first = controller.fetchScholarships(refresh: true);
    final second = controller.fetchScholarships(refresh: true);

    pending.complete(firstResponse);
    await Future.wait([first, second]);

    expect(repository.calls, 1);
    expect(controller.state, isA<ScholarshipDiscoverySuccess>());
  });
}
