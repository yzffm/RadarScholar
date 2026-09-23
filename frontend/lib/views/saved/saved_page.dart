import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/scholarship_card.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(savedScholarshipsControllerProvider.notifier)
          .fetchSavedScholarships();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beasiswa Tersimpan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Daftar pantauan beasiswa yang menarik minat Anda.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: Spacing.xl),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(savedScholarshipsControllerProvider);

    if (state is SavedScholarshipsLoading ||
        state is SavedScholarshipsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SavedScholarshipsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(savedScholarshipsControllerProvider.notifier)
                  .fetchSavedScholarships(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is SavedScholarshipsEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Belum Ada Beasiswa Tersimpan',
              message: 'Simpan beasiswa yang menarik agar Anda tidak lupa.',
            ),
            const SizedBox(height: Spacing.md),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Cari Beasiswa'),
            ),
          ],
        ),
      );
    }

    if (state is SavedScholarshipsSuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(savedScholarshipsControllerProvider.notifier)
            .fetchSavedScholarships(),
        child: ListView.builder(
          itemCount: state.savedScholarships.length,
          itemBuilder: (context, index) {
            final saved = state.savedScholarships[index];
            return Stack(
              children: [
                ScholarshipCard(scholarship: saved.scholarship),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: AppTheme.brandPrimary,
                    ),
                    onPressed: () {
                      ref
                          .read(savedScholarshipsControllerProvider.notifier)
                          .unsaveScholarship(saved.scholarship.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dihapus dari daftar tersimpan'),
                        ),
                      );
                    },
                    tooltip: 'Hapus dari tersimpan',
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
