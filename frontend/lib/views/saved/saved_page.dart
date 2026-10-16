import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/application_controller.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
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
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: Spacing.pagePadding(screenWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'WATCHLIST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Beasiswa Tersimpan',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daftar pantauan beasiswa yang menarik minat Anda untuk dipersiapkan.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(savedScholarshipsControllerProvider);
    final primaryColor = AppTheme.primaryOf(context);

    if (state is SavedScholarshipsLoading ||
        state is SavedScholarshipsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SavedScholarshipsError) {
      return ErrorState(
        message:
            'Daftar tersimpan belum dapat dimuat. Periksa koneksi dan coba lagi.',
        onRetry: () => ref
            .read(savedScholarshipsControllerProvider.notifier)
            .fetchSavedScholarships(),
      );
    }

    if (state is SavedScholarshipsEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum Ada Beasiswa Tersimpan',
        message:
            'Simpan beasiswa yang menarik saat menjelajah agar Anda tidak melewatkan tenggat waktu.',
        actionLabel: 'Cari Beasiswa',
        onAction: () => context.go('/discovery'),
      );
    }

    if (state is SavedScholarshipsSuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(savedScholarshipsControllerProvider.notifier)
            .fetchSavedScholarships(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: Spacing.xl),
          itemCount: state.savedScholarships.length,
          itemBuilder: (context, index) {
            final saved = state.savedScholarships[index];
            return Stack(
              children: [
                ScholarshipCard(scholarship: saved.scholarship),
                Positioned(
                  top: 14,
                  right: 112,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      onTap: () {
                        ref
                            .read(savedScholarshipsControllerProvider.notifier)
                            .unsaveScholarship(saved.scholarship.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dihapus dari daftar tersimpan'),
                          ),
                        );
                      },
                      child: Tooltip(
                        message: 'Hapus dari tersimpan',
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevatedOf(context),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppTheme.borderColorOf(context),
                            ),
                          ),
                          child: Icon(
                            Icons.bookmark_rounded,
                            color: primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
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
