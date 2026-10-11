import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/matching_controller.dart';
import '../../core/theme.dart';
import '../../models/scholarship.dart';
import '../../widgets/matched_scholarship_card.dart';
import '../../widgets/empty_state.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Cerdas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              ref
                  .read(matchingControllerProvider.notifier)
                  .fetchMatchedScholarships();
            },
          ),
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
    return Center(
      child: EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Belum Ada Rekomendasi',
        message:
            'Tidak ada beasiswa yang cocok dengan profil akademik Anda saat ini. Coba perbarui profil Anda.',
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final primary = AppTheme.primaryOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref
                    .read(matchingControllerProvider.notifier)
                    .fetchMatchedScholarships();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(MatchedScholarshipListResponse data) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(matchingControllerProvider.notifier)
                .fetchMatchedScholarships();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(Spacing.md),
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
