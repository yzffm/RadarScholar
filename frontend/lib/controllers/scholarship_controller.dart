import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scholarship.dart';
import '../repositories/scholarship_repository.dart';

sealed class ScholarshipDiscoveryState {
  const ScholarshipDiscoveryState();
}

class ScholarshipDiscoveryInitial extends ScholarshipDiscoveryState {
  const ScholarshipDiscoveryInitial();
}

class ScholarshipDiscoveryLoading extends ScholarshipDiscoveryState {
  const ScholarshipDiscoveryLoading();
}

class ScholarshipDiscoverySuccess extends ScholarshipDiscoveryState {
  final List<Scholarship> scholarships;
  final int page;
  final int totalPages;
  final bool hasMore;

  const ScholarshipDiscoverySuccess({
    required this.scholarships,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });
}

class ScholarshipDiscoveryEmpty extends ScholarshipDiscoveryState {
  final bool isSearch;
  const ScholarshipDiscoveryEmpty({this.isSearch = false});
}

class ScholarshipDiscoveryError extends ScholarshipDiscoveryState {
  final String message;
  const ScholarshipDiscoveryError(this.message);
}

class ScholarshipController extends StateNotifier<ScholarshipDiscoveryState> {
  final ScholarshipRepository _repository;

  String? _currentSearch;
  String? _currentStatus;

  ScholarshipController(this._repository)
    : super(const ScholarshipDiscoveryInitial());

  Future<void> fetchScholarships({
    bool refresh = false,
    String? search,
    String? status,
  }) async {
    // Determine page
    int targetPage = 1;
    List<Scholarship> existingItems = [];

    if (!refresh && state is ScholarshipDiscoverySuccess) {
      final currentState = state as ScholarshipDiscoverySuccess;
      if (!currentState.hasMore) return; // No more items to load
      targetPage = currentState.page + 1;
      existingItems = currentState.scholarships;
    }

    // Keep track of search and status if it's a new query (refresh or first load)
    if (targetPage == 1) {
      _currentSearch = search;
      _currentStatus = status;
    } else {
      search = _currentSearch;
      status = _currentStatus;
    }

    if (targetPage == 1) {
      state = const ScholarshipDiscoveryLoading();
    }

    try {
      final response = await _repository.getScholarships(
        page: targetPage,
        pageSize: 20,
        search: search,
        status: status,
      );

      final newItems = [...existingItems, ...response.items];

      if (newItems.isEmpty) {
        state = ScholarshipDiscoveryEmpty(
          isSearch: search != null && search.isNotEmpty,
        );
      } else {
        state = ScholarshipDiscoverySuccess(
          scholarships: newItems,
          page: response.page,
          totalPages: response.totalPages,
          hasMore: response.page < response.totalPages,
        );
      }
    } catch (e) {
      state = const ScholarshipDiscoveryError(
        'Gagal memuat beasiswa. Periksa koneksi internet dan coba lagi.',
      );
    }
  }

  Future<void> search(String query) async {
    await fetchScholarships(
      refresh: true,
      search: query,
      status: _currentStatus,
    );
  }

  Future<void> setStatusFilter(String? status) async {
    await fetchScholarships(
      refresh: true,
      search: _currentSearch,
      status: status,
    );
  }
}

final scholarshipControllerProvider =
    StateNotifierProvider<ScholarshipController, ScholarshipDiscoveryState>((
      ref,
    ) {
      final repo = ref.watch(scholarshipRepositoryProvider);
      return ScholarshipController(repo);
    });
