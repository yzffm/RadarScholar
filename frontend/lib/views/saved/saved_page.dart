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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beasiswa Tersimpan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Daftar pantauan beasiswa yang menarik minat Anda untuk dipersiapkan.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
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
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);

    if (state is SavedScholarshipsLoading ||
        state is SavedScholarshipsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SavedScholarshipsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Daftar tersimpan belum dapat dimuat. Periksa koneksi dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(
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
        child: EmptyState(
          icon: Icons.bookmark_border_rounded,
          title: 'Belum Ada Beasiswa Tersimpan',
          message:
              'Simpan beasiswa yang menarik saat menjelajah agar Anda tidak melewatkan tenggat waktu.',
          actionLabel: 'Cari Beasiswa',
          onAction: () => context.go('/discovery'),
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
                  top: 14,
                  right: 14,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_rounded,
                      color: primaryColor,
                      size: 22,
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
