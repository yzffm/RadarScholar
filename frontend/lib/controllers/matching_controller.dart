import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/repositories/matching_repository.dart';
import 'package:radarscholar/repositories/scholarship_repository.dart';
import 'package:radarscholar/services/api_service.dart';

part 'matching_controller.freezed.dart';

@freezed
class MatchingState with _$MatchingState {
  const factory MatchingState.initial() = _Initial;
  const factory MatchingState.loading() = _Loading;
  const factory MatchingState.success(MatchedScholarshipListResponse data) =
      _Success;
  const factory MatchingState.empty() = _Empty;
  const factory MatchingState.error(String message) = _Error;
}

final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MatchingRepository(apiService);
});

final matchingControllerProvider =
    StateNotifierProvider<MatchingController, MatchingState>((ref) {
      final repository = ref.watch(matchingRepositoryProvider);
      return MatchingController(repository);
    });

class MatchingController extends StateNotifier<MatchingState> {
  final MatchingRepository _repository;

  MatchingController(this._repository) : super(const MatchingState.initial());

  Future<void> fetchMatchedScholarships({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    state = const MatchingState.loading();
    try {
      final response = await _repository.getMatchedScholarships(
        page: page,
        pageSize: pageSize,
        search: search,
      );

      if (response.items.isEmpty) {
        state = const MatchingState.empty();
      } else {
        state = MatchingState.success(response);
      }
    } catch (e) {
      state = MatchingState.error(e.toString());
    }
  }
}
