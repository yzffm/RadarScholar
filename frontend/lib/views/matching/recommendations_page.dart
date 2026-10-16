import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/matching_controller.dart';
import '../../core/theme.dart';
import '../../models/scholarship.dart';
import '../../widgets/matched_scholarship_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() =>
      _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchingControllerProvider.notifier).fetchMatchedScholarships();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchingControllerProvider);
    final borderColor = AppTheme.borderColorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Cerdas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Segarkan',
            onPressed: () {
              ref
                  .read(matchingControllerProvider.notifier)
                  .fetchMatchedScholarships();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        empty: () => _buildEmptyState(),
        error: (message) => _buildErrorState(message),
        success: (data) => _buildSuccessState(data),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Belum Ada Rekomendasi',
      message:
          'Tidak ada beasiswa yang cocok dengan profil akademik Anda saat ini. Coba perbarui profil Anda.',
    );
  }

  Widget _buildErrorState(String message) {
    return ErrorState(
      title: 'Terjadi Kesalahan',
      message: message,
      onRetry: () {
        ref
            .read(matchingControllerProvider.notifier)
            .fetchMatchedScholarships();
      },
    );
  }

  Widget _buildSuccessState(MatchedScholarshipListResponse data) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(matchingControllerProvider.notifier)
                .fetchMatchedScholarships();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: data.items.length,
            itemBuilder: (context, index) {
              final matchedScholarship = data.items[index];
              return MatchedScholarshipCard(
                matchedScholarship: matchedScholarship,
              );
            },
          ),
        ),
      ),
    );
  }
}
