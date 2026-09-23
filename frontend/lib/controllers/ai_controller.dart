import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_explanation.dart';
import '../repositories/ai_repository.dart';

final aiExplanationProvider = FutureProvider.family<MatchExplanation, String>((
  ref,
  scholarshipId,
) async {
  final repository = ref.watch(aiRepositoryProvider);
  return await repository.getScholarshipAiExplanation(scholarshipId);
});
