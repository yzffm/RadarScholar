import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/matching_controller.dart';
import '../../core/theme.dart';
import '../../widgets/matched_scholarship_card.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() => _RecommendationsPageState();
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Cerdas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(matchingControllerProvider.notifier).fetchMatchedScholarships();
            },
          )
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: Spacing.md),
          Text(
            'Belum Ada Rekomendasi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Tidak ada beasiswa yang cocok dengan profil Anda saat ini.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            const SizedBox(height: Spacing.md),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            ElevatedButton(
              onPressed: () {
                ref.read(matchingControllerProvider.notifier).fetchMatchedScholarships();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(data) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(matchingControllerProvider.notifier).fetchMatchedScholarships();
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
    );
  }
}
