import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin.dart';
import '../models/scholarship.dart';
import '../repositories/admin_repository.dart';

final adminSourcesProvider = FutureProvider.autoDispose<List<ScholarshipSource>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getSources();
});

final adminCrawlRunsProvider = FutureProvider.autoDispose<CrawlRunListResponse>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getCrawlRuns(limit: 20);
});

class AdminSourcesController extends StateNotifier<AsyncValue<List<ScholarshipSource>>> {
  final AdminRepository _repo;
  final Ref _ref;

  AdminSourcesController(this._repo, this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final sources = await _repo.getSources();
      state = AsyncValue.data(sources);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSource(String sourceId) async {
    try {
      final updatedSource = await _repo.toggleSource(sourceId);
      
      // Update local state
      state = state.whenData((sources) {
        return sources.map((s) => s.id == sourceId ? updatedSource : s).toList();
      });
    } catch (e) {
      // Re-throw to handle in UI (e.g. snackbar)
      rethrow;
    }
  }
}

final adminSourcesControllerProvider = 
    StateNotifierProvider.autoDispose<AdminSourcesController, AsyncValue<List<ScholarshipSource>>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminSourcesController(repo, ref);
});
