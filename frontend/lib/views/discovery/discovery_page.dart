import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/scholarship_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/scholarship_card.dart';
import 'package:go_router/go_router.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final _searchController = TextEditingController();
  String _currentStatus = 'Semua'; // 'Semua', 'Aktif', 'Tidak Aktif'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Fetch initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(scholarshipControllerProvider.notifier)
          .fetchScholarships(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _onSearchSubmit(String value) {
    ref.read(scholarshipControllerProvider.notifier).search(value);
  }

  void _onFilterSelected(String status) {
    setState(() {
      _currentStatus = status;
    });

    String? apiStatus;
    if (status == 'Aktif') apiStatus = 'active';
    if (status == 'Tidak Aktif') apiStatus = 'inactive';

    ref.read(scholarshipControllerProvider.notifier).setStatusFilter(apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scholarshipControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Eksplorasi Beasiswa',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Jelajahi peluang beasiswa dari sumber resmi yang terverifikasi secara berkala.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Modern Search bar
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: primaryColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearchSubmit,
                        style: TextStyle(color: colors.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Cari nama beasiswa, instansi, atau penyedia...',
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmit('');
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Filter chips bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua', Icons.grid_view_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Aktif',
                      Icons.check_circle_outline_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tidak Aktif', Icons.history_rounded),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // AI Smart Recommendation Card (if authenticated)
              if (ref.watch(isAuthenticatedProvider)) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.isDark(context)
                        ? const LinearGradient(
                            colors: [Color(0xFF131D38), Color(0xFF1B2A4E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekomendasi Cerdas AI',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              'Cek kecocokan profil akademik Anda dengan beasiswa yang tersedia.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => context.push('/recommendations'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: const Text(
                          'Buka Matcher',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Main content area
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _currentStatus == label;
    final primaryColor = AppTheme.primaryOf(context);
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onFilterSelected(label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? primaryColor : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScholarshipDiscoveryState state) {
    if (state is ScholarshipDiscoveryLoading ||
        state is ScholarshipDiscoveryInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScholarshipDiscoveryError) {
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
                  .read(scholarshipControllerProvider.notifier)
                  .fetchScholarships(refresh: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is ScholarshipDiscoveryEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: state.isSearch
              ? 'Tidak menemukan beasiswa'
              : 'Belum ada beasiswa',
          message: state.isSearch
              ? 'Tidak ada beasiswa yang sesuai dengan pencarian atau filter Anda.'
              : 'Belum ada beasiswa yang tersedia saat ini.',
        ),
      );
    }

    if (state is ScholarshipDiscoverySuccess) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(scholarshipControllerProvider.notifier)
            .fetchScholarships(refresh: true),
        child: ListView.builder(
          itemCount: state.scholarships.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.scholarships.length) {
              // Reached the end, trigger load more
              final controller = ref.read(
                scholarshipControllerProvider.notifier,
              );
              if (!controller.isFetching) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) controller.fetchScholarships();
                });
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ScholarshipCard(scholarship: state.scholarships[index]);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
