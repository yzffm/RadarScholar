import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_assistant.dart';
import '../repositories/ai_repository.dart';

final aiAssistantControllerProvider =
    StateNotifierProvider.autoDispose<
      AiAssistantController,
      AsyncValue<AssistantResponse?>
    >((ref) {
      final repository = ref.watch(aiRepositoryProvider);
      return AiAssistantController(repository);
    });

class AiAssistantController
    extends StateNotifier<AsyncValue<AssistantResponse?>> {
  final AiRepository _repository;

  AiAssistantController(this._repository) : super(const AsyncValue.data(null));

  Future<void> getAssistantFeedback(
    String applicationId,
    AssistantRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getAssistantFeedback(
        applicationId,
        request,
      );
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
